module KeplerProcessor
  module Saveable

    def full_output_filename
      "#{@options[:output_path]}/#{output_filename}"
    end

    def output_filename
      nil # defaults to nil, child class must override output_filename in order to save
    end

    def save!(append = false)
      return unless output_filename
      od = output_data || input_data || []
      ::FileUtils.mkpath options[:output_path]
      raise FileExistsError if File.exist?(full_output_filename) && !options[:force_overwrite]
      LOGGER.info "Writing output to #{full_output_filename}: #{od.inspect}"
      CSV.open(full_output_filename, append ? "a" : "w+", :col_sep => "\t") do |csv|
        # impicitly truncate file by file mode when force overwriting
        od.each { |record| csv << record }
      end
      true
    end

  end
end
