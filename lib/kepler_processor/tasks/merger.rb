module KeplerProcessor
  class Merger < TaskBase

    def execute!
      super InputFileProcessor
    end

    class InputFileProcessor < InputFileProcessorBase
      def execute!
        super do
          pad_data
          slice!
        end
      end

      def pad_data
        self.input_data += pad_points
        input_data.sort_by! &:first
      end

      def std_range
        # the time gap between consecutive SC points is just over 0.00068 (0.0006811) and for LC data is just greater than 0.02
        @input_filename.split("_")[3].split(".").first == "slc" ? 0.0006811 : 0.020434
      end

      def pad_points
        points = []
        input_data.each_with_index do |value, index|
          gap_size = index >= input_data.size - 2 ? 0 : (( input_data[index+1].first - value.first ) / std_range).round
          if gap_size > 1
            pads = (1...gap_size).map { |i| [(i * std_range + value.first).round(6), nil] }
            points += pads
          end
        end
        points
      end

      def slice!
        @output_data = []
        input_data.each_slice(@options[:merge_ratio]) do |slice|
          process_slice slice
        end
      end

      def process_slice(slice)
        # delete padded points
        slice.delete_if { |point| point.any? &:nil? }

        # merge points if slice is correct size
        @output_data << [(slice.map { |e| e[0] }.inject(:+).to_f / @options[:merge_ratio]).round(5), (slice.map { |e| e[1] }.inject(:+).to_f / @options[:merge_ratio]).round(10)] if slice.size == @options[:merge_ratio]
      end

      def output_filename
        # Determine the output filename from header
        @input_filename.dup.split("/").last.insert(-9, "_#{@options[:merge_ratio]}to1")
      end

    end
  end
end
