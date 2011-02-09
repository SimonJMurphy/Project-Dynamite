module KeplerProcessor
  class Transformer < Base
    include KeplerDFT

    def run
      super do
        compute_amplitude_spectrum
        plot_DFT @spectrum.to_a if cadence == :slc
        plot_DFT @spectrum.to_a.select { |x| x[0] <= 24 }
      end
    end

    private

      def compute_amplitude_spectrum
        bandwidth = @input_data.last.first - @input_data.first.first
        final_frequency = cadence == :slc ? 100 : 24
        @spectrum = dft @input_data.map { |x| x[0] }, @input_data.map { |x| x[1] }, @input_data.size, bandwidth, final_frequency
      end

      def cadence
        @input_filename_without_extension.split("_")[3].to_sym
      end

      def peak_point(data)
        data.sort_by { |x| x[1] }.last
      end

      def plot_DFT(data)
        ::Gnuplot.open do |gp|
          ::Gnuplot::Plot.new(gp) do |plot|
            plot.terminal "png"
            plot.output "#{@options[:output_path]}/#{@input_filename_without_extension}_fourier_plot_0to#{data.last[0].round_to(0).to_i}.png"
            kic_number, data_type, season, cadence = @input_filename_without_extension.split("_")
            plot.title  "Fourier for #{kic_number} #{season} #{cadence}"
            peak = peak_point data
            plot.label "'Peak of #{peak[1].round_to 4} @ #{peak[0].round_to 4} c/d' at screen 0.6, screen 0.9"
            plot.ylabel "Amplitude (mag)"
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
