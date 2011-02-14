module KeplerProcessor
  class LightCurvePlotter < TaskRunBase

    def run
      super do
        plot
      end
    end

    private

      def plot
        ::Gnuplot.open do |gp|
          ::Gnuplot::Plot.new(gp) do |plot|
            plot.terminal "png size 900,300"
            plot.output "#{@options[:output_path]}/#{@input_filename_without_extension}_plot.png"
            plot.ylabel "Amplitude"
            plot.xlabel "BJD"

            x = @input_data.map { |point| point[0] }
            y = @input_data.map { |point| point[1] * 1000 }

            plot.data << ::Gnuplot::DataSet.new([x, y]) do |ds|
              ds.with = "lines"
              ds.notitle
            end
          end
        end
      end

  end
end