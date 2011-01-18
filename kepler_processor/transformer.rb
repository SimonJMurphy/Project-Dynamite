module KeplerProcessor
  class Transformer < Base
    include GSL

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
        @fit = Poly.fit(@input_data.map { |d| d[0] }.to_gsl_vector, @input_data.map { |d| d[1] }.to_gsl_vector, @options[:polynomial_degree])
      end

      def subtract_polynomial_fit!
        @formatted_data = @input_data.map { |p| p[1] -= @fit.at(p[0]).to_f || 0.0; p }
      end

      def compute_amplitude_spectrum
        dataset_length = @input_data.last[0] - @input_data.first[0]
        frequency_step = 1 / (10.0 * dataset_length)
        frequencies = (0..20).in_steps_of frequency_step

        @fourier = FourierTransform.new @input_data, frequencies
        @fourier.send(@options[:transform]) # runs either fft or dft transform
      end

      def plot_DFT
        ::Gnuplot.open do |gp|
          ::Gnuplot::Plot.new( gp ) do |plot|

            plot.terminal "png"
            plot.output "#{@input_filename.split(".")[0]}_fourier_plot.png"
            kic_number, data_type, season, cadence = @input_filename.split("/").last.split(".").first.split("_")
            plot.title  "Fourier for #{kic_number} #{season} #{cadence}"
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


