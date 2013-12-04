module KeplerProcessor
  class Appender < MultifileTaskBase

    attr_accessor :output_data
    include Saveable

    def execute!
      super do
        get_kic_numbers
        separate_by_kic_number
        process_stars
      end
    end

    private

      def get_kic_numbers
        @kic_numbers = @runners.map { |r| r.attributes[:kic_number] }.uniq
        # raise(RuntimeError, "All files must be for the same star") if @runners.map { |r| r.attributes[:kic_number] }.uniq.count > 1
      end

      def separate_by_kic_number
        @stars = []
        @kic_numbers.each do |kic|
          this_star = Array.new
          @runners.each do |runner|
            this_star << runner if kic == runner.attributes[:kic_number]
          end
          @stars << this_star
        end
      end

      def process_stars
        @stars.each_with_index do |star, index|
          @index = index
          collate_input_data
          save!
        end
      end

      def collate_input_data
        @output_data = @stars[@index].map { |runner| runner.input_data }.flatten 1
      end

      def output_filename
        flux_type = @stars[@index].first.input_filename_without_path.split("_")[1]
        "#{@stars[@index].first.attributes[:kic_number]}_appended-#{flux_type}_Q99_llc.txt"
      end
  end
end
