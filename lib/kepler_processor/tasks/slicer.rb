module KeplerProcessor
  class Slicer < TaskBase

    def execute!
      super Run
    end

    class Run < TaskRunBase
      def execute!
        super do
          slice
        end
      end

      private

        def slice
          # identify expected space between points, which may or may not be useful
          std_range = @input_filename.split("_").last.split(".").first == "slc" ? 0.00068 : 0.02
          @slice_size = @options[:slice_size] / std_range

          # slice the input data array into arrays of size slice_size
          # for each slice, save a series of output files named according to position in time (eg. @input_filename_slice4).
          @slices = []
          @input_data.each_slice(@slice_size) { |slice| @slices << slice }
        end

        def output_filename
          # Determine the output filename from input_filename and slice properties
          @input_filename.dup.split("/").last.insert(-9, "_#{@options[:slice_size]}d-slices-part#{@slice_number}")
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
