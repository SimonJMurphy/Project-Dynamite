module KeplerProcessor
  class Slicer < Base

    def run
      super Run
    end

    class Run < TaskRunBase
      def run
        super do
          slice
        end
      end

      private

        def slice
          # identify expected space between points, which may or may not be useful
          std_range = @input_filename.split("_")[3] == "slc" ? 0.00068 : 0.02

          # slice the input data array into arrays of size slice_size
          # for each slice, save a series of output files named according to position in time (eg. @input_filename_slice4).
          @slices = []
          @input_data.each_slice(@options[:slice_size]) { |slice| @slices << slice }
        end

        def output_filename
          # Determine the output filename from input_filename and slice properties
          @input_filename.dup.split("/").last.insert(-5, "_#{@options[:slice_size]}d_slices_part#{@slice_number}")
        end

        def save!
          @slices.each_with_index do |slice, i|
            @slice_number = i
            @output_data = slice
            super
          end
        end
    end
  end
end
