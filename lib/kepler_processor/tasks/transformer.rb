module KeplerProcessor
  class Transformer < Base
    include KeplerDFT

    def run
      super do
        compute_amplitude_spectrum
        plot_DFT
      end
    end

    private

      def compute_amplitude_spectrum
        bandwidth = @input_data.last.first - @input_data.first.first
        @spectrum = dft(@input_data.map { |x| x[0] }, @input_data.map { |x| x[1] }, @input_data.size, bandwidth).to_a
      end

      def peak_frequency
        @spectrum.sort_by { |x| x[1] }.last[0]
      end

      def plot_DFT
        ::Gnuplot.open do |gp|
          ::Gnuplot::Plot.new(gp) do |plot|
            plot.terminal "png"
            plot.output "#{@options[:output_path]}/#{@input_filename_without_extension}_fourier_plot.png"
            kic_number, data_type, season, cadence = @input_filename_without_extension.split("_")
            plot.title  "Fourier for #{kic_number} #{season} #{cadence}. Peak frequency is #{peak_frequency.round_to 4} with amplitude" # #{@spectrum[peak_frequency].round_to 4}"
            plot.ylabel "Amplitude (mag)"
            plot.xlabel "Frequency (c/d)"

            x = @spectrum.map { |pair| pair[0] }
            y = @spectrum.map { |pair| pair[1] }

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


