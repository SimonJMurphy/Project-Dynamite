module KeplerProcessor
  class LightCurvePlotter < Base

    def run
      super do
        plot
      end
    end

    private

      def plot
        ::Gnuplot.open do |gp|
          ::Gnuplot::Plot.new(gp) do |plot|
            plot.terminal "png size 1000,500"
            plot.output "#{@options[:output_path]}/#{@input_filename_without_extension}_plot.png"
            kic_number, data_type, season, cadence = @input_filename_without_extension.split("_")
            plot.title  "Lightcurve of #{kic_number} #{season} #{cadence}"
            plot.ylabel "Amplitude"
            plot.xlabel "Time"

            x = @input_data.map { |point| point[0] }
            y = @input_data.map { |point| point[1] }

            plot.data << ::Gnuplot::DataSet.new([x, y]) do |ds|
              ds.with = "lines"
              ds.notitle
            end
          end
        end
      end

  end
end