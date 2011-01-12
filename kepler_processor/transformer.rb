module KeplerProcessor
  class Transformer < Base

    include GSL

    # FT Parameters - TODO: take as arguments
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
        @formatted_data = @input_data.map { |p| p[1] -= @fit.at(p[0]).to_f || 0.0; p }
      end

      def compute_amplitude_spectrum
        signal = @input_data.map { |d| d[1] }
        @fourier = FourierTransform.new(signal.size, @options[:samplerate])
        @fourier.send(@options[:transform], signal) # runs either fft or dft transform

        puts "[#{@options[:transform].to_s.upcase}] Sample rate: #{@fourier.samplerate.freq_to_per_day} c/d.  Buffer size: #{@fourier.buffersize} samples\n\n"
        puts "      Found fundamental peak frequency of #{@fourier.peak_frequency.freq_to_per_day.round_to(5)}c/d +/- #{(@fourier.bandwidth/2.0).freq_to_per_day.round_to(5)}\n\n"
      end

      def plot_DFT
        # y2    = @fft.subvector(1, @input_data.size-2).to_complex2
        # mag   = y2.abs
        # phase = y2.arg
        # f     = Vector.linspace 0, SAMPLING/2, mag.size
        # graph f, mag, "-T png -C -g 3 -x 0 200 -X 'Frequency [Hz]' > fft.png"
        
        @fourier.spectrum.each { |p| puts p.inspect }
        @fourier.plot
      end

      def plot_lightcurve

      end

      # no output filename method, because we don't want to save any text, just the plots.
  end
end