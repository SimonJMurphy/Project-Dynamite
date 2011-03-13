module KeplerProcessor
  class CLI
    desc 'append', 'Append multiple datafiles together'
    common_method_options
    def append
      clean_options
      Appender.new(options).execute!
    end
  end

  class Appender < MultifileTaskBase

    attr_accessor :output_data
    include Saveable

    def execute!
      super do
        check_consistent_kic_number
        sort_runners_by_season
        collate_input_data
        reinsert_header
        save!
      end
    end

    private

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
  end
end
