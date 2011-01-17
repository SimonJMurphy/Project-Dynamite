module KeplerProcessor
  class Computor < Base

    def run
      super do
        dft
      end
    end

    def dft
      initial_frequency = 0.0
      final_frequency = 100.0
      dataset_length = @input_data.last[0] - @input_data.first[0]
      frequency_step = 1 / (10.0 * dataset_length)
      i = 0
      j = 0
      k = 0.0

      @output_data = []
      @input_data.each do |line|                        # |line| is representing 'i' - more intuitive and ruby-like
        while k < dataset_length do |j|
          k = j * frequency_step                        # = f_j
          cos_i = Math.cos(2 * Math::PI * k * @input_data.map { |line| line[0])  # may need to rewrite to access zero'th column of i'th line properly? :s
          sin_i = Math.sin(2 * Math::PI * k * @input_data.map { |line| line[0])

          fr += cos_i * line[1]
          fi += sin_i * line[1]

          amp_j = 2 * Math.sqrt(fr * fr + fi * fi) / @input_data.size
          phi_j = Math.atan2(-fi / fr)

          @output_data << "#{k} #{amp_j} #{phi_j}"      # probably a better way of doing this
          j += 1
        end
      end
    end

    puts @output_data.inspect

  end
end
