module KeplerProcessor
  class CLI
    desc 'detrend', 'Remove linear trends in data'
    common_method_options
    def detrend
      clean_options
      Detrender.new(options).execute!
    end
  end

  class Detrender < TaskBase

    def execute!
      super InputFileProcessor
    end

    class InputFileProcessor < InputFileProcessorBase
      def execute!
        super do
          calculate_fit
          subtract_fit!
        end
      end

      private

        def calculate_fit
          @fit_c, @fit_m = GSL::Fit::linear @input_data.map(&:first).to_gslv, @input_data.map(&:last).to_gslv
        end

        def subtract_fit!
          @output_data = @input_data.map do |point|
            x, y = point
            fitdiff = (@fit_m * x) + @fit_c
            [x, y - fitdiff]
          end
        end

        def output_filename
          @input_filename_without_path.dup.insert -9, "_detrended"
        end
    end

  end
end
