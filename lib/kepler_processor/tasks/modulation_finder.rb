module KeplerProcessor
  class ModulationFinder < MultifileTaskBase
    include FourierTransformable
    include KeplerDFT

    def execute!
      super(InputFileProcessor) do
        sort_by_part_number
        find_mid_point
        peak_points = @runners.map { |runner| runner.peak_point(runner.spectrum) }
        peak_frequencies = peak_points.map { |p| p[0] }
        peak_amplitudes = peak_points.map { |p| p[1] }
        plot @mid_points, peak_frequencies, "BJD -2400000", "frequency of highest peak", "freq-time"
        plot @mid_points, peak_amplitudes, "BJD -2400000", "amplitude of highest peak", "amp-time"
        peak_freq_FT = compute_amplitude_spectrum peak_frequencies
        plot peak_freq_FT.map { |x| x[0] }, peak_freq_FT.map { |x| x[1] }, "frequency of frequency-variation (/d)", "amplitude", "freq-mod-FT"
        peak_amp_FT = compute_amplitude_spectrum peak_amplitudes
        plot peak_amp_FT.map { |x| x[0] }, peak_amp_FT.map { |x| x[1] }, "frequency of amplitude-variation (/d)", "amplitude", "amp_mod-FT"        
        LOGGER.info "Peak Frequency Mean: #{peak_frequencies.mean}"
        LOGGER.info "Peak Frequency Standard Deviation: #{peak_frequencies.standard_deviation}"
        LOGGER.info "Peak Amplitude Mean: #{peak_amplitudes.mean}"
        LOGGER.info "Peak Amplitude Standard Deviation: #{peak_amplitudes.standard_deviation}"
      end
    end

    def find_mid_point
      @runners.each do |runner|
        # add the time of the first point to half of the difference in time between final and first points
        mid_point = runner.input_data.first.first + (runner.input_data.last.first - runner.input_data.first.first) / 2
        @mid_points ||= []
        @mid_points << mid_point
      end
    end

    def sort_by_part_number
      @runners.sort! { |a,b| a.part_number <=> b.part_number }
      @runners.delete_at(-1) # don't use last slice, there are often too few points and it might fuck up the results
    end
    
    def compute_amplitude_spectrum(source_data = nil)
      source_data ||= input_data
      # automatically determine the nyquist frequency from the time span of each dataset, then make that the final frequency of the DFT
      final_frequency = (@runners.first.input_data.last.first - @runners.first.input_data.first.first) * 0.5
      time_span_of_dataset = @runners.last.input_data.last.first - @runners.first.input_data.first.first
      dft (0..source_data.size).to_a, source_data, source_data.size, time_span_of_dataset, final_frequency
    end
    
    def plot(x, y, x_label, y_label, name)
      ::Gnuplot.open do |gp|
        ::Gnuplot::Plot.new(gp) do |plot|
          plot.terminal "png size 900,300"
          plot.output "#{@options[:output_path]}/#{@runners.first.input_filename_without_path.split("_").first}_#{name}_modulation.png"
          plot.xlabel x_label
          plot.ylabel y_label

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
