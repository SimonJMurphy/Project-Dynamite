module KeplerProcessor
  class MultifileTaskBase < TaskBase

    attr_accessor :input_data

    def initialize(*args)
      super
      @runners = []
    end

    def execute!
      begin
        check_input_file_count
        get_input_files
        execute_all_runners
        check_consistent_kic_number
        sort_runners_by_season
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
        raise(RuntimeError, "Two or more input files required") if @options[:input_paths].count < 2
      end

      def get_input_files
        @options[:input_paths].each do |input_path|
          @runners << InputFileProcessor.new(input_path, @options)
        end
      end

      def execute_all_runners
        @runners.each &:execute!
      end

      def check_consistent_kic_number
        raise(RuntimeError, "All files must be for the same star") if @runners.map { |r| r.attributes[:kic_number] }.uniq.count > 1
      end

      def sort_runners_by_season
        @runners.sort! { |a,b| a.attributes[:season] <=> b.attributes[:season] }
      end

    class InputFileProcessor < InputFileProcessorBase
    end
  end
end
