module KeplerProcessor
  class Transformer < Base

    def run
      super do
        compute_amplitude_spectrum
        plot_DFT
        plot_lightcurve
      end
    end

    private

      def zero_pad_input
        @input_data.pad_to_next_power_of_two_with [0,0]
      end

      def compute_amplitude_spectrum
        dataset_length = @input_data.last[0] - @input_data.first[0]
        zero_pad_input
        frequency_step = 1 / (10.0 * dataset_length)
        frequencies = (0..20).in_steps_of frequency_step

        @fourier = FourierTransform.new @input_data, frequencies
        @fourier.dft
      end

      def plot_DFT
        ::Gnuplot.open do |gp|
          ::Gnuplot::Plot.new( gp ) do |plot|

            plot.terminal "png"
            plot.output "#{@input_filename.split(".")[0]}_fourier_plot.png"
            kic_number, data_type, season, cadence = @input_filename.split("/").last.split(".").first.split("_")
            peak_frequency = @fourier.peak_frequency
            plot.title  "Fourier for #{kic_number} #{season} #{cadence}. Peak frequency is #{peak_frequency.round_to 4} with amplitude #{@fourier.spectrum[peak_frequency].round_to 4}"
            plot.ylabel "Amplitude (mag)"
            plot.xlabel "Frequency (c/d)"

            x = @fourier.spectrum.map { |pair| pair[0] }
            y = @fourier.spectrum.map { |pair| pair[1] }

            plot.data << ::Gnuplot::DataSet.new( [x, y] ) do |ds|
              ds.with = "lines"
              ds.notitle
            end
          end
        end
      end

      def plot_lightcurve

      end

      # no output filename method, because we don't want to save any text, just the plots.
  end
end


