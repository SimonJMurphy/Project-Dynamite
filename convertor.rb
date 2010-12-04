#!/usr/bin/env ruby
require 'gsl'
module KeplerProcessor
  class FileExistsError < StandardError; end
  class NoDataError < StandardError; end

  class Base
    def initialize(input_filename, force_overwrite)
      @input_filename = input_filename
      @force_overwrite = force_overwrite
      @input_data = []
    end

    def run
      puts "Processing file #{@input_filename}"
      read_in_data
      split_comments!
      parse_header_attributes
      convert_from_string!
      yield
      save!
      puts "Finished processing file #{@input_filename}"
    end

    private

      def read_in_data
        File.new(@input_filename, "r").each { |line| @input_data << line }
        # file closes automatically because it's opened in this method
        raise NoDataError if @input_data.empty?
      end

      def split_comments!
        @comments, @input_data = @input_data.partition { |line| line =~ /^#/ } # matches (=~) regular expression (//) hash at start of line (^)
      end

      def parse_header_attributes
        # selects lines from comments containing a colon, maps them into an array, removing the '#' and splitting about that colon. Creates a hash out of the result.
        @attributes = @comments.select { |line| line.include? ":" }.map { |line| line.gsub("# ", "").split ":" }.to_hash
      end

      def convert_from_string!
        # @input_data is being converted to a two dimensional float array: time, flux
        @input_data.map! { |line| line.split(" ").map(&:to_f)[0..1] }
      end

      def output_filename
        nil # defaults to nil, child class must override output_filename in order to save.
      end

      def save!
        if output_filename
          @output_data ||= @input_data
          raise FileExistsError if File.exist?(output_filename) && !@force_overwrite
          output_file = File.new output_filename, "a+" # 'a' for all - read, write... everything
          output_file.truncate(0) if @force_overwrite # essentially confines the size of the file to zero if forcibly overwritten, thereby emptying the file.
          @output_data.each { |record| output_file << "#{record.join("\t")}\n" } # outputs the array, joining each row element separated by tab, and each line by newline.
        end
      end
  end

  class Convertor < Base

    def run
      super do
        strip_invalid!
        convert_fluxes_to_magnitudes!
        center_mag_on_zero!
      end
    end

    private

      def strip_invalid!
        @input_data.delete_if { |record| record[1] == 0.0 }
      end

      def convert_fluxes_to_magnitudes!
        @input_data.each { |record| record[1] = -2.5 * Math.log10(record[1]) }
      end

      def average_mag
        @input_data.map { |record| record[1] }.inject(:+).to_f / @input_data.size
      end

      def center_mag_on_zero!
        average = average_mag
        @input_data.each { |record| record[1] -= average }
      end

      def output_filename
        # Determine the output filename from header
        "kic#{@attributes[:kic_number]}_#{@attributes[:season]}_#{@input_filename.split("_")[1]}.txt"
      end
  end

  class Transformer < Base
    include GSL

    # define parameters for FT (eventually to be given as arguments)
    DEG       = 2       # degree of polynomial to subtract from the data
    SAMPLING  = 1000    # 1 kHz
    F_INITIAL = 0.03    # lower frequency limit for amplitude spectrum, c/d
    F_FINAL   = 24      # upper frequency limit for amplitude spectrum, c/d
    DELTA_F   = 0.02    # frequency step (to be updated to 1/10T eventually), c/d

    def run
      super do
        calculate_polynomial_fit
        subtract_polynomial_fit!
        compute_amplitude_spectrum
        plot_DFT
        plot_lightcurve
      end
    end

    private
      def calculate_polynomial_fit
        # @input_data is currently an array of arrays e.g [ [time1, mag1], [time2, mag2] ... ]
        # need an array of the times, and an array of the mags to apply a fit to, final argument is degree of fit
        @fit = Poly.fit(@input_data.map { |d| d[0] }.to_gsl_vector, @input_data.map { |d| d[1] }.to_gsl_vector, DEG)
      end

      def subtract_polynomial_fit!
        @formatted_data = @input_data.map do |p|
          fit_point = @fit.at(p[0]).to_f || 0.0
          p[1] -= fit_point
          p
        end
      end

      def compute_amplitude_spectrum
        @fft = @input_data.map { |d| d[1] }.to_gsl_vector.fft
      end

      def plot_DFT
        y2 = @fft.subvector(1, @input_data.size-2).to_complex2
        mag = y2.abs
        phase = y2.arg
        f = Vector.linspace 0, SAMPLING/2, mag.size
        graph f, mag, "-T png -C -g 3 -x 0 200 -X 'Frequency [Hz]' > fft.png"
      end

      def plot_lightcurve

      end
      # no output filename method, because we don't want to save any text, just the plots.
  end
end

class Array
  def to_hash
    self.inject({}) { |accumulator, element| accumulator[element[0].downcase.gsub(" ", "_").to_sym] = element[1].gsub(" ", "").strip; accumulator }
    # creating an empty hash with inject. The key is made lower case and spaces swapped to underscore.
  end
end

Kernel.abort "Please pass the input filename as an argument! Use -f to force overwrite." if ARGV.size < 1 #aborts the execution if no filename is provided as an argument with the program call

possible_methods = { "convert" => KeplerProcessor::Convertor, "transform" => KeplerProcessor::Transformer}
method = ARGV.delete_at 0

force_overwrite = false

if ARGV.first == "-f" # the zeroth element of ARGV, equivalent of ARGV[0]
  force_overwrite = true
  ARGV.delete_at 0 # need to remove the -f because it's not a filename we want to convert.
end

ARGV.each do |filename|
  begin
    possible_methods[method].new(filename, force_overwrite).run
  rescue KeplerProcessor::FileExistsError
    puts "Your output file (#{filename}) already exists, please remove it first (or something)."
  end
end