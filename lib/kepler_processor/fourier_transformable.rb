module KeplerProcessor
  module FourierTransformable
    
    def compute_amplitude_spectrum(source_data = nil)
      source_data ||= input_data
      dataset_length_in_time = source_data.last.first - source_data.first.first
      final_frequency = cadence == :slc ? 100 : 24
      dft source_data.map { |x| x[0] }, source_data.map { |x| x[1] }, source_data.size, dataset_length_in_time, final_frequency
    end

    def cadence
      input_filename_without_extension.split("_")[3].to_sym
    end

    def peak_point(data)
      data.sort_by { |x| x[1] }.last
    end
    
  end
end