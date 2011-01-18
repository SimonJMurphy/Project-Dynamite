module KeplerProcessor
  class FourierTransform
    attr_reader :spectrum

    def initialize buffer, analysis_frequencies
    end

    def dft
    end

    def peak_frequency
    end
end

# def dft
#   # Output data is a hash of frequency-complex number pairs, with a new line for each frequency step.
#   @output_data = {}
#
#   # populates a hash with initial zero values (quicker here than in the loop)
#   frequencies.each { |f| @output_data[f] = Complex(0,0) }
#
#   @input_data.each do |line|
#     time, magnitude = line
#     frequencies.each do |f|
#       omega_t = 2 * Math::PI * f * time
#       @output_data[f] += Complex(Math.cos(omega_t) * magnitude, Math.sin(omega_t) * magnitude) # complex(real, imaginary)
#     end
#   end
#   @output_data.each { |f, val| @output_data[f] = @output_data[f].magnitude * 2 / @input_data.size }
# end