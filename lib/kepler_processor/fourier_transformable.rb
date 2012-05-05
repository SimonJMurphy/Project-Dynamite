module KeplerProcessor
  module FourierTransformable
    
    def compute_amplitude_spectrum(source_data = nil)
      source_data ||= input_data
      time_span_of_dataset = source_data.last.first - source_data.first.first
      final_frequency = cadence == :slc ? 100 : 24
      dft source_data.map { |x| x[0] }, source_data.map { |x| x[1] }, source_data.size, time_span_of_dataset, final_frequency
    end

    def cadence
      input_filename_without_extension.split("_")[3].to_sym
    end

    def peak_point(data)
      @sorted_data = data.sort_by { |x| x[1] }
      @sorted_data.last
    end

    def percentile_95(data)
      percentile = (@sorted_data.size * 0.95).round_to 0
      @sorted_data[percentile]
    end

  end
end