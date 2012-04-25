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
          plot_DFT spectrum.to_a.select { |x| x[0] <= 24 }
          if @options[:export]
            note_amplitudes
            save! true
          end
        end
      end

      private

        def plot_DFT(data)
          ::Gnuplot.open do |gp|
            ::Gnuplot::Plot.new(gp) do |plot|
              plot.terminal "png size 900,300"
              # plot.format 'y "%6.3f"'
              plot.lmargin "10"
              plot.output "#{@options[:output_path]}/#{@input_filename_without_extension}_fourier_plot_0to#{data.last[0].round_to(0).to_i}.png"
              peak = peak_point data
              @amplitude = peak[1].round_to 3
              @frequency = peak[0].round_to 4
              plot.label "'Peak of #{@amplitude} mmag at #{@frequency} c/d' at screen 0.70, screen 0.034"
              plot.ylabel "Amplitude (mmag)"
              plot.xlabel "Frequency (c/d)"

              x = data.select { |x| x[0] }
              y = data.select { |x| x[1] }

              plot.data << ::Gnuplot::DataSet.new([x, y]) do |ds|
                ds.with = "lines"
                ds.notitle
              end
            end
          end
        end

        def note_amplitudes
          @output_data = []
          @output_data << [@attributes[:kic_number], @attributes[:season], @amplitude, @frequency]
        end

        def output_filename
          "fourier_information.txt"
        end
    end
  end
end
