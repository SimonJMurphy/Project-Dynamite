module KeplerProcessor
  class Matcher < MultifileTaskBase

    attr_accessor :output_data
    include Saveable

    def execute!
      @options[:file_columns] = (0..3).to_a
      super do
        produce_arrays
        match_observation_cycle
        report_missing_entries
        sort_results
        save!
      end
    end

    private

    def produce_arrays
      @observation_index = if @runners.first.input_filename_without_path.include? 'observation_index'
        @runners.first.input_data
      else
        @runners.last.input_data
      end
      
      @fourier_information = if @runners.first.input_filename_without_path.include? 'fourier_information'
        @runners.first.input_data
      else
        @runners.last.input_data
      end
      @observation_index.each { |line| line.compact! }
    end

    def match_observation_cycle
      @fourier_information.each do |line|
        line[0].gsub!('kic','')
        @observation_index.each do |observation_cycle|
          if observation_cycle.first.include?(line[0]) && observation_cycle.first.include?(line[1])
            observation_cycle.first.insert(-1, ",#{line[2]},#{line[3]}")
          end
        end
      end
      @output_data = @observation_index.map { |line| line.first.split(",").to_a }
    end

    def report_missing_entries
      @output_data.each do |line|
        puts "\t#{line[0]} (#{line[2]}) does not have the expected number of attributes. Fourier information is probably not appended." if line.size < 10
      end
    end

    def sort_results
      @output_data.sort! do |a, b|
        comparison_result = a[0] <=> b[0]
        comparison_result = a[2] <=> b[2] if comparison_result == 0
        @output_data.delete(a) if comparison_result == 0
        comparison_result
      end
    end

    def output_filename
      "matched_table.txt"
    end
  end
end
