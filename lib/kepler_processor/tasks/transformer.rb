module KeplerProcessor
  class Transformer < TaskBase

    def execute!
      super InputFileProcessor
    end

    class InputFileProcessor < InputFileProcessorBase
      include KeplerDFT
      include FourierTransformable
      
      attr_accessor :spectrum

      def initialize(*args)
        super
        @txt_save = false
      end

      def execute!
        super do
          @spectrum = compute_amplitude_spectrum
          plot_DFT spectrum.to_a if cadence == :slc
          llc_upper_limit = @options[:fourier_range] ? @options[:fourier_range].split(",").last.to_f : 24.0
          data = spectrum.to_a.select { |x| x[0] <= llc_upper_limit }
          plot_DFT data
          if @options[:export]
            determine_grass_level data
            note_amplitudes
            save! true
          end
          if @options[:print]
            print_fourier_information spectrum.to_a
            save! true
          end
        end
      end

      private

      def plot_DFT(data)
        ::Gnuplot.open do |gp|
          ::Gnuplot::Plot.new(gp) do |plot|
            plot.terminal "png size 1800,600 font \"arial,20\""
            # plot.format 'y "%6.3f"'
            plot.lmargin "10"
            plot.output "#{@options[:output_path]}/#{@input_filename_without_extension}_fourier_plot_#{data.first[0].round_to(0).to_i}to#{data.last[0].round_to(0).to_i}.png"
            plot.border   "linewidth 2"

            peak = peak_point data
            @amplitude = peak[1].round_to 3
            @frequency = peak[0].round_to 4
            plot.label "'Peak of #{@amplitude} mmag at #{@frequency} c/d' at screen 0.70, screen 0.034"
            plot.ylabel "Amplitude (mmag)"
            plot.xlabel "Frequency (c/d)"

            x = data.select { |x| x[0] }
            y = data.select { |x| x[1] }

            plot.data << ::Gnuplot::DataSet.new([x, y]) do |ds|
              ds.with = "lines lw 2"
              ds.notitle
            end
          end
        end
      end

      def determine_grass_level(data)
        percentile = percentile_95 data
        @grass_level = percentile.round_to 4
      end

      def note_amplitudes
        @output_data = []
        if @attributes[:season].to_s == "Q0" || @attributes[:season].to_s == "Q1"
          @attributes[:season].to_s.insert(-1,".0") if cadence == :slc
        end
        @output_data << [@attributes[:kic_number], @attributes[:season], @amplitude, @frequency, @grass_level]
      end

      def print_fourier_information(data)
        @output_data = data
      end

      def output_filename
        if @options[:export]
          "fourier_information.txt"
        else @options[:print]
          "#{@input_filename_without_path.dup.insert(-5, '_fou')}"
        end
      end
    end
  end
end
