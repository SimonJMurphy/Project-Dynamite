module KeplerProcessor
  class IndexDupRemover < Base

    def execute!
      super Run
    end

    class Run < TaskRunBase
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
          "improved_observation_index.txt"
        end
    end
  end
end
