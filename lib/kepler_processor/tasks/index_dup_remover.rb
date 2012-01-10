module KeplerProcessor
  class IndexDupRemover < TaskBase

    def execute!
      @options[:column_delimiter] = ","
      @options[:file_columns] = (0..8).to_a
      @options[:column_converters] = [:integer, :float, :float, :float, :float, :float, :float, :float, :float]
      super InputFileProcessor
    end

    class InputFileProcessor < InputFileProcessorBase
      def execute!
        super do
          kill_duplicates!
        end
      end

      private

      # in terminal, specify columns 0,1,2,3,4,5,6. Table to include: KIC-10 number, Magnitude, Teff (K), Radius, log G, [Fe/H], Contamination.

        def kill_duplicates!
          encountered_kic_nums = []
          @output_data = @input_data.select do |obs|
            encountered = encountered_kic_nums.include? obs[0]
            encountered_kic_nums << obs[0]
            !encountered
          end
          @output_data.each { |star| star[0] = star[0].to_i }
        end

        def output_filename
          if options[:keep_name]
            "#{@input_filename_without_extension.split("/").last}_improved.txt"
          else
          "improved_observation_index.txt"
          end
        end
    end
  end
end
