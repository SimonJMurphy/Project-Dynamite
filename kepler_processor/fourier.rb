module KeplerProcessor
  class FourierTransform
    attr_reader :spectrum

    def initialize(input_data, analysis_frequencies)
      @input_data = input_data
      @analysis_frequencies = analysis_frequencies

      # Make spectrum a hash of frequency-complex number pairs for the loop (phase is important when adding), then replace with freq-amp pairs
      @spectrum = {}

      # populates a hash with initial zero values (quicker here than in the loop)
      @analysis_frequencies.each { |f| @spectrum[f] = Complex(0,0) }
    end

    def peak_frequency
      @spectrum.sort_by { |x| x[1] }.last[0]
    end

    def dft
      @input_data.each do |point|
        time, magnitude = point
        @analysis_frequencies.each do |f|
          omega_t = 2 * Math::PI * f * time
          @spectrum[f] += Complex(Math.cos(omega_t) * magnitude, Math.sin(omega_t) * magnitude) # complex(real, imaginary) magnitude is brightness
        end
      end
      @spectrum.each { |f, val| @spectrum[f] = @spectrum[f].magnitude * 2 / @input_data.size } # magnitude of the complex number
      @spectrum
    end
  end
end