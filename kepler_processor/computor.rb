module KeplerProcessor
  class Computor < Base

    def run
      super do
        dft
        plot
      end
    end

    def dft
      dataset_length = @input_data.last[0] - @input_data.first[0]
      frequency_step = 1 / (10.0 * dataset_length)
      frequencies = (0..20).in_steps_of frequency_step

      # Output data is a hash of frequency-complex number pairs, with a new line for each frequency step.
      @output_data = {}

      # populates a hash with initial zero values (quicker here than in the loop)
      frequencies.each { |f| @output_data[f] = Complex(0,0) }

      @input_data.each do |line|
        time, magnitude = line
        frequencies.each do |f|
          omega_t = 2 * Math::PI * f * time
          @output_data[f] += Complex(Math.cos(omega_t) * magnitude, Math.sin(omega_t) * magnitude) # complex(real, imaginary)
        end
      end
      @output_data.each { |f, val| @output_data[f] = @output_data[f].magnitude * 2 / @input_data.size }
    end

    def plot
      ::Gnuplot.open do |gp|
        ::Gnuplot::Plot.new( gp ) do |plot|

          plot.terminal "png"
          plot.output "#{@input_filename.split(".")[0]}_fourier_plot.png"
          kic_number, data_type, season, cadence = @input_filename.split("/").last.split(".").first.split("_")
          plot.title  "Fourier for #{kic_number} #{season} #{cadence}"
          plot.ylabel "Amplitude (mag)"
          plot.xlabel "Frequency (c/d)"

          x = @output_data.map { |pair| pair[0] }
          y = @output_data.map { |pair| pair[1] }

          plot.data << ::Gnuplot::DataSet.new( [x, y] ) do |ds|
            ds.with = "lines"
            ds.notitle
          end
        end
      end
    end

  end
end
