module KeplerProcessor
  class Appender < MultifileTaskBase

    attr_accessor :output_data
    include Saveable

    def execute!
      super do
        collate_input_data
        reinsert_header
        save!
      end
    end

    private

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
  end
end
