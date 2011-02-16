module KeplerProcessor
  class Slicer < Base

    def run
      super Run
    end

    class Run < TaskRunBase
      def run
        super do
          slice!
        end
      end

      private

        def slice!
          # identify expected space between points, which may or may not be useful
          std_range = @input_filename.split("_")[3] == "slc" ? 0.00068 : 0.02

          # slice the input data array into arrays of size slice_size
          # for each slice, save a series of output files named according to position in time (eg. @input_filename_slice4).
          @output_data = []
          @slice_number = 0
          @input_data.each_slice(@options[:slice_size]) do |slice|
            slice.each { |s| @output_data << s }
            save!
            @slice_number += 1
          end
        end

        def output_filename
          # Determine the output filename from input_filename and slice properties
          @input_filename.dup.split("/").last.insert(-5, "_#{@options[:slice_size]}d_slices_part#{@slice_number}")
        end
        
        def save!
          if output_filename
            @output_data ||= @input_data
            ::FileUtils.mkpath @options[:output_path]
            raise FileExistsError if File.exist?(full_output_filename) && !@options[:force_overwrite]
            LOGGER.info "Writing output to #{full_output_filename}"
            CSV.open(full_output_filename, @options[:force_overwrite] ? "w+" : "a+", :col_sep => "\t") do |csv|
              # impicitly truncate file by file mode when force overwriting
              @output_data.each { |record| csv << record }
            end
          end
        end
    end
  end
end
