module KeplerProcessor
  class Merger < TaskBase

    def execute!
      super InputFileProcessor
    end

    class InputFileProcessor < InputFileProcessorBase
      def execute!
        super do
          merge!
        end
      end

      private

        def merge!
          # the time gap between consecutive SC points is just over 0.00068 (0.0006811) and for LC data is just greater than 0.02
          # therefore, if the data is SC, as indicated by input_filename, take the first value for std_range, if not, take second.
          std_range = @input_filename.split("_")[3].split(".").first == "slc" ? 0.00068 : 0.020434

          @output_data = []
          @starting_ref = 0
          while @starting_ref < (@input_data.size - @options[:merge_ratio]) # i.e. while not at the last (incomplete) slice
            slice = @input_data[@starting_ref, @options[:merge_ratio]] # take ** one ** slice from a given start point at a time
            p slice.size # it's taking more than one slice, the sly bastard.
            if ( slice.last[0] - slice.first[0] ) > ( @options[:merge_ratio] * std_range ) # if there is a gap ... find points in gap
              i = 0, gap_start = []
              while gap_start.empty?
                if ( slice[i+1].first - slice[i].first ) > ( 1.5 * std_range )
                  gap_start = slice[i].first.to_f
                  gap_end = slice[i+1].first.to_f
                end
                i += 1
              end
              points_in_gap = (( gap_end - gap_start ) / std_range ).round
              @starting_ref += @options[:merge_ratio] - ((i - 1) + points_in_gap) # correct next start ref for number of points in gap
            elsif slice.size < @options[:merge_ratio]
              @starting_ref += @options[:merge_ratio]
            else
              @output_data << [slice.map { |e| e[0] }.inject(:+).to_f / @options[:merge_ratio], slice.map { |e| e[1] }.inject(:+).to_f / @options[:merge_ratio]] # slice is good, send it to output data. Proceed as normal with start ref.
              @starting_ref += @options[:merge_ratio]
            end
          end


          # slice the input data array into arrays of size merge_ratio
          # for each slice, replace the slice by the arithmetic mean value, unless there is a time gap in the data greater than the std gap or <[merge_ratio] items in slice (eof).
        #   @output_data = []
        #   @scrap_data = []
        #   @input_data.each_slice(@options[:merge_ratio]) do |slice|
        #     if ( slice.last[0] - slice.first[0] ) > ( @options[:merge_ratio] * std_range ) || slice.size < @options[:merge_ratio]
        #       slice.each { |s| @scrap_data << s } # Don't average things out
        #     else
        #       @output_data << [slice.map { |e| e[0] }.inject(:+).to_f / @options[:merge_ratio], slice.map { |e| e[1] }.inject(:+).to_f / @options[:merge_ratio]]
        #     end
        #   end
        # end

        def output_filename
          # Determine the output filename from header
          @input_filename.dup.split("/").last.insert(-9, "_#{@options[:merge_ratio]}to1")
        end
      end
    end
  end
end
