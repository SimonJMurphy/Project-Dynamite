module KeplerProcessor
  class Merger < Base

    def run
      super do
        merge!
      end
    end

    private

    #  def calculate_averages
    #   @input_data.map { |record| record[1] }.inject(:+).to_f / @input_data.size
    #  end

    def merge!
      # need to average the times over merge_ratio values, along with the corresponding fluxes, then replace by a single averaged value
      # => sum #{merge_ratio} values
      # => convert to float
      # => divde by merge_ratio (to get average)
      # => replace those #{merge_ratio} values by the single averaged value for each of time and flux
      # => if t[ i + merge_ratio ] - t[i] > merge_ratio * standard_time_gap_between_points, do not replace this set of points
      # => => this is so that when there is a time gap, we do not try to merge points over that time gap, just leave alone instead.
    end

    def output_filename
      # Determine the output filename from header
      "kic#{@attributes[:kic_number]}_#{@attributes[:season]}_#{@input_filename.split("_")[1]}_#{options[:merge_ratio]}to1.txt"
    end

  end
end
