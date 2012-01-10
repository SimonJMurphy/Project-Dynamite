module KeplerProcessor
  class MultifileTaskBase < TaskBase

    attr_accessor :input_data

    def initialize(*args)
      super
      @runners = []
    end

    def execute!(processor = InputFileProcessorBase)
      begin
        @processor = processor
        check_input_file_count
        get_input_files
        execute_all_runners
        yield if block_given?
      rescue KeplerProcessor::FileExistsError
        LOGGER.info "Your output file (#{full_output_filename}) already exists, please remove it first (or something)."
      rescue => e
        LOGGER.error e.message
        LOGGER.error e.backtrace.join("\n")
      end
    end

    private
      def check_input_file_count
        raise(RuntimeError, "Two or more input files required") if @options[:input_paths].count < 2 unless options[:command] == Inspector
      end

      def get_input_files
        @options[:input_paths].each do |input_path|
          @runners << @processor.new(input_path, @options)
        end
      end

      def execute_all_runners
        @runners.each &:execute!
      end
  end
end
