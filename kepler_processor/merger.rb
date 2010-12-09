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
        @input_filename.split("_")[1] = "slc" ? std_range = 0.00068 : std_range = 0.02

        # separate the input_data array into times and fluxes arrays, then slice those into arrays of size merge_ratio
        # for each slice, replace the slice by the arithmetic mean value, unless there is a time gap in the data greater than the std gap
        @times = @input_data.map { |column| column[0] }.each_slice(merge_ratio) do |slice|
          slice = inject(:+).to_f / merge_ratio unless ( slice.last - slice.first ) > ( merge_ratio * std_range )
        end
        @fluxes = @input_data.map {|column| column [1] }.each_slice(merge_ratio) do |slice|
          slice = inject(:+).to_f / merge_ratio unless ( slice.last - slice.first ) > ( merge_ratio * std_range )
      end

      def output_filename
        # Determine the output filename from header
        "kic#{@attributes[:kic_number]}_#{@attributes[:season]}_#{@input_filename.split("_")[1]}_#{options[:merge_ratio]}to1.txt"
      end

  end
end
