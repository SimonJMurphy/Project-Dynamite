module KeplerProcessor
  class TaskBase
    attr_accessor :options

    def initialize(options)
      @options = options
    end

    def execute!(input_file_processor)
      @options[:input_paths].each do |filename|
        begin
          c = input_file_processor.new filename, @options
          c.execute!
        rescue KeplerProcessor::FileExistsError
          LOGGER.info "Your output file (#{c.full_output_filename}) already exists, please remove it first (or something)."
        rescue => e
          LOGGER.error e.exception
        ensure
          c = nil
        end
      end
    end
  end
end
