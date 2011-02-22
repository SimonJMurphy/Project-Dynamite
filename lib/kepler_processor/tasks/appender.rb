module KeplerProcessor
  class Appender < Base

    include Saveable
    attr_accessor :input_data, :output_data

    def initialize(*args)
      super
      @runners = []
    end

    def run
      check_input_file_count
      get_input_files
      collate_input_data
      save!
    end

    private
      def check_input_file_count
        raise(RuntimeError, "Two or more input files required") if @options[:input_paths].count < 2
      end

      def get_input_files
        @options[:input_paths].each do |input_path|
          @runners << Run.new(input_path, @options)
        end
      end

      def collate_input_data
        @output_data = @runners.map { |runner| runner.input_data }.flatten 1
      end

      def output_filename
        @runners.first.input_filename_without_path.sub(/\d{13}/, "appended_#{@runners.first.season}-#{@runners.last.season}") # Timestamp always has 13 digits in it
      end

    class Run < TaskRunBase
    end
  end
end
