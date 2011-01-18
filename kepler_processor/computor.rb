module KeplerProcessor
  class Computor < Base

    def run
      super do
        dft
        plot
      end
    end

    def dft
      dataset_length = @input_data.last[0] - @input_data.first[0]   # gives length of dataset in days by difference in final and initial time
      frequency_step = 1 / (10.0 * dataset_length)                  # step is 1/10T
      frequencies = (0..20).in_steps_of frequency_step
      @output_data = {}
      frequencies.each { |f| @output_data[f] = Complex(0,0) }       # creates a hash with zero values for all frequencies being used (quicker here than in loop)

      @input_data.each do |line| # |line| is representing 'i' - more intuitive and ruby-like
        time = line[0]
        magnitude = line[1]
        frequencies.each do |f|

          omega_t = 2 * Math::PI * f * time
          cos_i = Math.cos omega_t
          sin_i = Math.sin omega_t

          real_component = 0
          imaginary_component = 0
          real_component += cos_i * magnitude           # the sum? of all the cosine terms times the magnitudes
          imaginary_component += sin_i * magnitude

          # Amplitude calculated using product rather than ^2 in the hope of saving computing time
          # amp_j = 2 * Math.sqrt(real_component * real_component + imaginary_component * imaginary_component) / @input_data.size
          # phi_j = (Math.atan(-imaginary_component / real_component))

          # Output data is a hash of frequency-complex number pairs, with a new line for each frequency step.
          @output_data[f] += Complex(real_component, imaginary_component)
        end
      end
    end

    def plot
      ::Gnuplot.open do |gp|
        ::Gnuplot::Plot.new( gp ) do |plot|

          plot.terminal "png"
          plot.output "#{@input_filename.split(".")[0]}_fourier_plot.png"
          plot.title  "Sample Fourier"
          plot.ylabel "Amplitude"
          plot.xlabel "Frequency"

          x = @output_data.map { |pair| pair[0] }
          y = @output_data.map { |pair| pair[1].magnitude }

          plot.data << ::Gnuplot::DataSet.new( [x, y] ) do |ds|
            ds.with = "lines"
            ds.notitle
          end
        end
      end
    end

  end
end
