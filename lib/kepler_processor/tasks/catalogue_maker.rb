require 'prawn'

module KeplerProcessor
  class CatalogueMaker < Base

    def run
      @options[:column_delimiter] = ","
      @options[:file_columns] = (0..6).to_a
      super Run
    end

    class Run < TaskRunBase
      CATALOGUE_IMAGES_PATH = "Users/sjm/code/Project-Dynamite/data/output/wg4_catalogue_images/"
      def run
        super do
          create_star_metadata_hash
          create_observation_index
          create_pdf
        end
      end

      def create_star_metadata_hash
        @star_metadata = {}
        @input_data.each do |star|
          @star_metadata[star[0].to_i] = { :magnitude => star[3], :t_eff => star[4], :radius => star[5], :log_g => star[6], :feh => star[7], :contamination => star[8] }
        end
      end

      def create_observation_index
        @observation_index = @input_data.map do |observation|
          kic_number, cadence, season = observation
          kic_number = kic_number.to_i
          cadence = cadence == "SC" ? "slc" : "llc"
          hash = { :kic_number => kic_number, :cadence => cadence, :season => season, :cycle => "kic#{kic_number} #{season} #{cadence}", :lightcurve_path => "#{CATALOGUE_IMAGES_PATH}kic#{kic_number}_CFlux_#{season}_#{cadence}_plot.png", :short_fourier_path => "#{CATALOGUE_IMAGES_PATH}kic#{kic_number}_CFlux_#{season}_#{cadence}_fourier_plot_0to24.png" }
          hash[:long_fourier_path] = "#{CATALOGUE_IMAGES_PATH}kic#{kic_number}_CFlux_#{season}_#{cadence}_fourier_plot_0to100.png" if cadence == "slc"
          hash
        end
      end

      # input_filenames of the form:        kic10000056_CFlux_Q4.2_slc.txt
      # lightcurve_filenames of the form:   kic10000056_CFlux_Q4.2_slc_plot.png
      # fourier_plot_filenames of the form: kic10000056_CFlux_Q4.2_slc_fourier_plot_0to100.png

      def create_pdf
        observation_index = @observation_index
        Prawn::Document.generate(full_output_filename, :page_layout => :portrait, :margin => 5, :skip_page_creation => false) do
          observation_index.each do |observation|
            start_new_page

            image observation[:lightcurve_path], :at => [0,750], :width => 580
            image observation[:short_fourier_path], :at => [0, 560], :width => 580
            image observation[:long_fourier_path], :at => [0, 360], :width => 580

            font_size(20) { draw_text observation[:cycle], :at => [5, 760] }

            star_metadata = @star_metadata[observation[:kic_number]]

            draw_text "log g \t = #{star_metadata[:log_g]}", :at => [420, 770]
            draw_text "[Fe/H] = #{star_metadata[:feh]}", :at => [420, 755]
            draw_text "Teff \t = #{star_metadata[:t_eff]}", :at => [520, 770]
            draw_text "radius = #{star_metadata[:radius]}", :at => [520, 755]
          end

          number_pages "page <page> of <total>", [bounds.right - 80, 0] # must go at end to number all pages
        end
      end
    end
  end
end
