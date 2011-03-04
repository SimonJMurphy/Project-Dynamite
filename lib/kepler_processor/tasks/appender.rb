module KeplerProcessor
  class Appender < TaskBase

    attr_accessor :input_data, :output_data
    include Saveable

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
        collate_input_data
        reinsert_header
        save!
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

      def collate_input_data
        @output_data = @runners.map { |runner| runner.input_data }.flatten 1
      end

      def reinsert_header
        @output_data.insert 0, ["# KIC number: #{@runners.first.attributes[:kic_number]}"]
        @output_data.insert 0, ["# Season: #{season_range}"]
      end

      def season_range
        @season_range ||= "#{@runners.first.attributes[:season]}-#{@runners.last.attributes[:season]}"
      end

      def output_filename
        @runners.first.input_filename_without_path.sub(/\d{13}/, "appended_#{season_range}") # Timestamp always has 13 digits in it
      end

    class InputFileProcessor < InputFileProcessorBase
    end
  end
end
