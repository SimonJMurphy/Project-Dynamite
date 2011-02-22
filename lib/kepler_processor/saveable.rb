module KeplerProcessor
  module Saveable
    def full_output_filename
      "#{@options[:output_path]}/#{output_filename}"
    end

    def output_filename
      nil # defaults to nil, child class must override output_filename in order to save
    end

    def save!
      if output_filename
        output_data ||= input_data
        ::FileUtils.mkpath options[:output_path]
        raise FileExistsError if File.exist?(full_output_filename) && !options[:force_overwrite]
        LOGGER.info "Writing output to #{full_output_filename}"
        CSV.open(full_output_filename, options[:force_overwrite] ? "w+" : "a+", :col_sep => "\t") do |csv|
          # impicitly truncate file by file mode when force overwriting
          output_data.each { |record| csv << record }
        end
      end
    end
  end
end
