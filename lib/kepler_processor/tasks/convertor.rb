module KeplerProcessor
  class Convertor < TaskBase

    def execute!
      super InputFileProcessor
    end

    class InputFileProcessor < InputFileProcessorBase
      def execute!
        super do
          strip_invalid!
          correct_time!
          convert_fluxes_to_magnitudes!
          center_mag_on_zero!
        end
      end

      private

        def strip_invalid!
          @input_data.delete_if { |record| record =~ /$(i)/ || record[1] == "-Inf" || record[1] == "NaN" || record[0] == "NaN" || record[1] == "nan" || record[1].nil? }
        end

        def correct_time!
          @input_data.each { |record| record[0] += 55833.0 } if options[:time]
        end

        def convert_fluxes_to_magnitudes!
          @input_data.each { |record| record[1] = -2.5 * Math.log10(record[1]) }
        end

        def average_mag
          @avg_mag ||= @input_data.map { |record| record[1] }.inject(:+).to_f / @input_data.size
        end

        def center_mag_on_zero!
          @input_data.each { |record| record[1] -= average_mag }
        end

        def flux_type
          if flux_type = @input_filename.match(/(\w)flux/)
            "#{flux_type[1]}flux"
          else
            @options[:file_columns] == [0, 1] ? :Rflux : :Cflux
          end
        end

        def output_filename          
          @output_filename ||= if options[:batch]
            # For converting an entire quarter when input stars are in folders like data/input/wg4:
            "converted_#{@input_filename.split("/")[2]}/kic#{[@attributes[:kic_number], flux_type, @attributes[:season], @input_filename.split("_").last.split(".").first].compact.join('_')}.txt"
          elsif options[:keep_name]
            "#{@input_filename_without_extension.split("/").last}_converted.txt"
          else
            # For individual stars, in raw name format on their own
            "kic#{[@attributes[:kic_number], flux_type, @attributes[:season], @input_filename.split("_").last.split(".").first].compact.join('_')}.txt"
          end
        end
    end

  end
end
