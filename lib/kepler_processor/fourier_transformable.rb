module KeplerProcessor
  module FourierTransformable
    
    def compute_amplitude_spectrum
      bandwidth = input_data.last.first - input_data.first.first
      final_frequency = cadence == :slc ? 100 : 24
      dft input_data.map { |x| x[0] }, input_data.map { |x| x[1] }, input_data.size, bandwidth, final_frequency
    end

    def cadence
      input_filename_without_extension.split("_")[3].to_sym
    end

    def peak_point(data)
      data.sort_by { |x| x[1] }.last
    end
    
  end
end