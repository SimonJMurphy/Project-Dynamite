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
            plot.terminal "png"
            plot.output "#{@input_filename.split(".")[0]}_plot.png"
            plot.title  "Sample Lightcurve"
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