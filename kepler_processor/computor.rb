module KeplerProcessor
  class Computor < Base

    def run
      super do
        dft
      end
    end

    def dft
      final_frequency = 100.0
      dataset_length = @input_data.last[0] - @input_data.first[0]   # gives length of dataset in days by difference in final and initial time
      frequency_step = 1 / (10.0 * dataset_length)                  # step is 1/10T
      j = 0       # looping from zero is the same as setting the starting frequency of the range to be analysed to zero.
      k = 0.0

      @output_data = []
      @input_data.each do |line|                        # |line| is representing 'i' - more intuitive and ruby-like
        time = line[0]
        magnitude = line[1]
        while k < final_frequency do |j|
          k = j * frequency_step                        # k represents the frequency currently being looked at, or f_j
          cos_i = Math.cos(2 * Math::PI * k * time)
          sin_i = Math.sin(2 * Math::PI * k * time)

          real_component += cos_i * magnitude           # the sum of all the cosine terms times the magnitudes
          imaginary_component += sin_i * magnitude

          # Amplitude calculated using product rather than ^2 in the hope of saving computing time
          amp_j = 2 * Math.sqrt(real_component * real_component + imaginary_component * imaginary_component) / @input_data.size
          phi_j = Math.atan2(-imaginary_component / real_component)

          # Output data array will have three columns, frequency, amplitude and phase (separated by spaces), and a line for each frequency step
          @output_data << "#{k} #{amp_j} #{phi_j}"
          j += 1
        end
      end
    end

    puts @output_data.inspect

  end
end
