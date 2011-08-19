require 'gsl'

module KeplerProcessor
  class Fitter < TaskBase
    
    def execute!
      super InputFileProcessor
      @options[:column_converters] = [:float, :float]
    end

    class InputFileProcessor < InputFileProcessorBase
      def execute!
        super do
          @output_data ||= @input_data
          # @output_data.delete_at -1
          calculate_fit
          check_points
        end
      end
      
      private

        def calculate_fit # we're going to assume the initial distribution of points is good
          @fit_c, @fit_m = GSL::Fit::linear @output_data.map(&:first).to_gslv, @output_data.map(&:last).to_gslv
          p @fit_m, @fit_c
        end
        
        def check_points
          @output_data.each { |point| point[1] += 2 * Math::PI if (point[1] - (@fit_m * point[0] + @fit_c)) < -Math::PI }
          @output_data.each { |point| point[1] -= 2 * Math::PI if (point[1] - (@fit_m * point[0] + @fit_c)) > Math::PI }
          calculate_fit
        end

        # output new y-values
        def output_filename
          @output_data.each { |point| point[1].round_to 5}
          @input_filename_without_path.dup.insert -5, "_fitted"
        end
    end
  end
end