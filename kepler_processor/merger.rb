module KeplerProcessor
  class Merger < Base

    def run
      super do
        merge!
      end
    end

    private

      def merge!
        # the gap between consecutive points it time for slc data is just over 0.00068 and for llc data is just greater than 0.02
        # therefore, if the data is slc, as indicated by input_filename, take the first value for std_range, if not, take second.
        std_range = @input_filename.split("_")[1] == "slc" ? 0.00068 : 0.02

        # separate the input_data array into times and fluxes arrays, then slice those into arrays of size merge_ratio
        # for each slice, replace the slice by the arithmetic mean value, unless there is a time gap in the data greater than the std gap
        @output_data = []
        @input_data.each_slice(@options[:merge_ratio]) { |slice| @output_data.push slice }
        @output_data.map! do |slice|
          if ( slice.last[0] - slice.first[0] ) > ( @options[:merge_ratio] * std_range ) || ( slice.last[1] - slice.first[1] ) > ( @options[:merge_ratio] * std_range )
            slice # Don't average things out
          else
            [slice.map { |e| e[0] }.inject(:+).to_f / @options[:merge_ratio], slice.map { |e| e[1] }.inject(:+).to_f / @options[:merge_ratio]]
          end
        end
        @output_data.flatten!
      end

      def output_filename
        # Determine the output filename from header
        @input_filename.dup.split("/").last.insert(-5, "_#{@options[:merge_ratio]}to1")
      end

  end
end
