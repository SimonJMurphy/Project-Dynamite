require 'fileutils'
require 'csv'

module KeplerProcessor
  class Base

    def initialize(input_filename, options)
      @input_filename                   = input_filename
      input_filename_without_path       = @input_filename.split("/").last.split(".")
      input_filename_without_path.delete_at(-1)
      @input_filename_without_extension = input_filename_without_path.join '.'
      @options                          = options
      @input_data                       = []
    end

    def run
      LOGGER.info "Processing file #{@input_filename}"
      read_in_data
      split_comments!
      parse_header_attributes
      convert_from_string!
      yield
      save!
      LOGGER.info "Finished processing file #{@input_filename}"
    end

    def full_output_filename
      "#{@options[:output_path]}/#{output_filename}"
    end

    private

      def read_in_data
        File.open(@input_filename, "r") do |file|
          file.each { |line| @input_data << line }
        end
        raise NoDataError if @input_data.empty?
      end

      def split_comments!
        # matches (=~) regular expression (/../) hash at start of line (^), preceeded by any number of spaces (\s*)
        @comments, @input_data = @input_data.partition { |line| line =~ /^(\s*#)/ }
      end

      def parse_header_attributes
        # select lines from comments containing a colon, map them into an array, remove the '#' and split
        # about that colon. Create a hash out of the result.
        @attributes = @comments.select { |line| line.include? ":" }.map { |line| line.gsub("# ", "").split ":" }.to_hash
      end

      def convert_from_string!
        # convert @input_data to a two dimensional float array: time, flux
        @input_data.map! do |line|
          l = line.split(" ").map &:to_f
          [l[@options[:file_columns][0]], l[@options[:file_columns][1]]]
        end
      end

      def output_filename
        nil # defaults to nil, child class must override output_filename in order to save
      end

      def save!
        if output_filename
          @output_data ||= @input_data
          ::FileUtils.mkpath @options[:output_path]
          raise FileExistsError if File.exist?(full_output_filename) && !@options[:force_overwrite]
          LOGGER.info "Writing output to #{full_output_filename}"
          CSV.open(full_output_filename, @options[:force_overwrite] ? "w+" : "a+", :col_sep => "\t") do |csv|
            # impicitly truncate file by file mode when force overwriting
            @output_data.each { |record| csv << record }
          end
        end
      end

  end
end
