module KeplerProcessor
  class Convertor < Base
    def run
      super do
        strip_invalid!
        convert_fluxes_to_magnitudes!
        center_mag_on_zero!
      end
    end

    private

      def strip_invalid!
        @input_data.delete_if { |record| record[1] == 0.0 }
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
        # Determine the output filename from header
        "kic#{@attributes[:kic_number]}_#{@attributes[:season]}_#{@input_filename.split("_")[1]}.txt"
      end
  end
end