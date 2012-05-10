module KeplerProcessor
  class Matcher < MultifileTaskBase

    attr_accessor :output_data
    include Saveable

    def execute!
      @options[:file_columns] = (0..4).to_a
      super do
        produce_arrays
        patch_early_sc
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

    def patch_early_sc
      @observation_index.each do |line|
        line.first.gsub!("Q0","Q0.0") if line.first.include? "SC,Q0,"
        line.first.gsub("Q1","Q1.1") if line.first.include? "SC,Q1,"
      end
      p @observation_index
    end

    def match_observation_cycle
      puts "Cross-examining input files. Transfering fourier information..."
      @output_data ||= []
      @fourier_information.each do |line|
        line[0].gsub!('kic','')
        @observation_index.each_with_index do |observation_cycle, index|
          if observation_cycle.first.include?(line[0]) && observation_cycle.first.include?(line[1])
            observation_cycle.first.insert(-1, ",#{line[2]},#{line[3]},#{line[4]}")
            @output_data << observation_cycle.first.split(",").to_a
            @observation_index.delete_at index
            break
          end
        end
      end
      leftovers = @observation_index.map { |line| line.first.split(",").to_a }
      leftovers.each { |line| @output_data << line }
      puts "Transfer of Fourier information complete. Identifying any observations missing information..."
    end

    def report_missing_entries
      @output_data.each do |line|
        puts "\t#{line[0]} (#{line[2]}) does not have the expected number of attributes. Fourier information is probably not appended." if line.size < 10
      end
    end

    def sort_results
      puts "Sorting the results by KIC number and season, removing duplicates..."
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
