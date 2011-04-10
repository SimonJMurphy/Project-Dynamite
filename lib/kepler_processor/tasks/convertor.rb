module KeplerProcessor
  class Convertor < TaskBase

    def execute!
      super InputFileProcessor
    end

    class InputFileProcessor < InputFileProcessorBase
      def execute!
        super do
          strip_invalid!
          convert_fluxes_to_magnitudes!
          center_mag_on_zero!
        end
      end

      private

        def strip_invalid!
          @input_data.delete_if { |record| record =~ /$(i)/ || record[1] == "-Inf" }
        end

        def convert_fluxes_to_magnitudes!
          @input_data.each { |record| record[1] = -2.5 * Math.log10(record[1]) }
        end

        def average_mag
          @input_data.map { |record| record[1] }.inject(:+).to_f / @input_data.size
        end

        def center_mag_on_zero!
          average = average_mag
          @input_data.each { |record| record[1] -= average }
        end

        def output_filename
          if options[:batch]
            # For converting an entire quarter when input stars are in folders like data/input/wg4:
            "converted_#{@input_filename.split("/")[2]}/kic#{@attributes[:kic_number]}_CFlux_#{@attributes[:season]}_#{@input_filename.split("_").last.split(".").first}.txt"
          else
            # For individual stars, in raw name format on their own in data/input (assuming CFlux and default output directory data/output):
            "kic#{@attributes[:kic_number]}_CFlux_#{@attributes[:season]}_#{@input_filename.split("_").last.split(".").first}.txt"
          end
        end
    end

  end
end
