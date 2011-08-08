require 'polynomial'

module KeplerProcessor
  class PhaseFinder < TaskBase

    def execute!
      super InputFileProcessor
    end

    class InputFileProcessor < InputFileProcessorBase
      def execute!
        @options[:column_delimiter] = "\t"
        @options[:file_columns] = (0..5)
        super do
          index
          calculate_combinations
          piify
        end
      end

      private

        def index
          @input_data.map do |line|
            line.tap { |l| l[0] = l[0].sub("F", "").to_i if line[0] }
          end
        end

        def calculate_combinations
          @output_data = @input_data.map do |line|
            unless line[4].nil?
              poly = Polynomial[line[4].sub("=", '').sub('-f', '-1f'), :power_symbol => '', :variable_name => 'f', :multiplication_symbol => '']
              combination = line[3]
              combination_error = line[5] ** 2
              poly.coefs.each_with_index do |coef, pos|
                combination -= phases[pos] * coef
                combination_error += ( phase_errors[pos] ** 2 ) * coef.abs
              end
              line << combination
              line << combination_error ** 0.5
            end
            line
          end
        end
        
        def phases
          @phases ||= @input_data.inject({0 => 0}) do |accumulator, element|
            accumulator[element[0]] = element[3] if element[0]
            accumulator
          end
        end        
        
        def phase_errors
          @phase_errors ||= @input_data.inject({0 => 0}) do |accumulator, element|
            accumulator[element[0]] = element[5] if element[0]
            accumulator
          end
        end
        
        def piify
          @output_data.each do |line|
            unless line[6].nil?
              while line[6].abs > Math::PI
                line[6] -= 2 * Math::PI if line[6] > Math::PI
                line[6] += 2 * Math::PI if line[6] < -Math::PI
              end
            end
          end
        end

        def output_filename          
          @input_filename_without_path.dup.insert -5, "_phazered"
        end
    end
  end
end
