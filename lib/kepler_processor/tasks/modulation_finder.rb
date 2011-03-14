module KeplerProcessor
  class ModulationFinder < MultifileTaskBase
    include FourierTransformable
    include KeplerDFT

    def execute!
      super(InputFileProcessor) do
        sort_by_part_number
        peak_points = @runners.map { |runner| runner.peak_point(runner.spectrum) }
        peak_frequencies = peak_points.map { |p| p[0] }
        peak_amplitudes = peak_points.map { |p| p[1] }
        peak_freq_FT = compute_amplitude_spectrum peak_frequencies
        plot peak_freq_FT, "frequency"
        peak_amp_FT = compute_amplitude_spectrum peak_amplitudes
        plot peak_amp_FT, "amplitude"
        LOGGER.info "Peak Frequency Mean: #{peak_frequencies.mean}"
        LOGGER.info "Peak Frequency Standard Deviation: #{peak_frequencies.standard_deviation}"
        LOGGER.info "Peak Amplitude Mean: #{peak_amplitudes.mean}"
        LOGGER.info "Peak Amplitude Standard Deviation: #{peak_amplitudes.standard_deviation}"
      end
    end

    def sort_by_part_number
      @runners.sort! { |a,b| a.part_number <=> b.part_number }
    end
    
    def compute_amplitude_spectrum(source_data = nil)
      source_data ||= input_data
      dft (0..source_data.size).to_a, source_data, source_data.size, source_data.size, 50 # last argument is final frequency
    end
    
    def plot(what, label)
      ::Gnuplot.open do |gp|
        ::Gnuplot::Plot.new(gp) do |plot|
          plot.terminal "png size 900,300"
          plot.output "#{@options[:output_path]}/#{:kic_number}_#{label}-modulation.png"
          plot.xlabel "Frequency of #{label}-variation"
          plot.ylabel "Amplitude"

          x = what.map { |point| point[0] }
          y = what.map { |point| point[1] }

          plot.data << ::Gnuplot::DataSet.new([x, y]) do |ds|
            ds.with = "lines"
            ds.notitle
          end
        end
      end
    end

    class InputFileProcessor < InputFileProcessorBase
      include KeplerDFT
      include FourierTransformable

      attr_accessor :spectrum

      def execute!
        super do
          @spectrum = compute_amplitude_spectrum
        end
      end
      
      def part_number
        /([\w\d]*)part(\d+)(\w*)/.match(@input_filename_without_path)[2].to_i
      end

    end
  end
end
