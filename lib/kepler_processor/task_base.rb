module KeplerProcessor
  class TaskBase
    attr_accessor :options, :errors

    def initialize(options)
      @options = options
      @errors = []
    end

    def execute!(input_file_processor)
      @options[:input_paths].each do |filename|
        begin
          c = input_file_processor.new filename, @options
          c.execute!
        rescue KeplerProcessor::FileExistsError
          message = "Your output file (#{c.full_output_filename}) already exists, please remove it first (or something)."
          LOGGER.info message
          errors << message
        rescue => e
          LOGGER.error e.message
          LOGGER.error e.backtrace.join("\n")
          errors << e.message
        ensure
          c = nil
          PBAR.inc
        end
      end
      unless errors.count.zero?
        LOGGER.error "The following errors occurred:"
        errors.each { |e| LOGGER.error e}
      end
    end
  end
end
