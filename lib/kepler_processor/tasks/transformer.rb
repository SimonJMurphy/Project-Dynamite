module KeplerProcessor
  class CLI
    desc 'transform', 'Produce fourier transforms of input data'
    common_method_options
    def transform
      clean_options
      Transformer.new(options).execute!
    end
  end

  class Transformer < TaskBase

    def execute!
      super InputFileProcessor
    end

    class InputFileProcessor < InputFileProcessorBase
      include KeplerDFT
      include FourierTransformable
      
      attr_accessor :spectrum

      def execute!
        super do
          @spectrum = compute_amplitude_spectrum
          plot_DFT spectrum.to_a if cadence == :slc
          plot_DFT spectrum.to_a.select { |x| x[0] <= 24 }
        end
      end

      private

        def plot_DFT(data)
          ::Gnuplot.open do |gp|
            ::Gnuplot::Plot.new(gp) do |plot|
              plot.terminal "png size 900,300"
              plot.output "#{@options[:output_path]}/#{@input_filename_without_extension}_fourier_plot_0to#{data.last[0].round_to(0).to_i}.png"
              peak = peak_point data
              plot.label "'Peak of #{peak[1].round_to 3} mmag at #{peak[0].round_to 3} c/d' at screen 0.71, screen 0.034"
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

        # no output filename method, because we don't want to save any text, just the plots.
    end
  end
end
