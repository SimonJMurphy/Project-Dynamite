require 'prawn'

module KeplerProcessor
  class CatalogueMaker < Base

    def run
      super do
        create_observation_index_hash
        build_up_data
        create_pdf
      end
    end

    def create_observation_index_hash
      puts @input_data.inspect
      @star_metadata = { 10000056 => { :log_g => 5832958, :feh => 427482, :t_eff => 4387238, :radius => 2321 } }
      # use this to get kic nums and corresponding parameters
      # one key:value pair for kic num => other values, then one for each of those values representing parameter => corresponding numerical value
    end

    # input_filenames of the form:        kic10000056_CFlux_Q4.2_slc.txt
    # lightcurve_filenames of the form:   kic10000056_CFlux_Q4.2_slc_plot.png
    # fourier_plot_filenames of the form: kic10000056_CFlux_Q4.2_slc_fourier_plot_0to100.png

    def build_up_data
      @page_data = [{ :kic_number => 10000056, :cycle => "kic10000056 Q4.2 slc", :lightcurve_path => "kic10000056_CFlux_Q4.2_slc_plot.png", :long_fourier_path => "kic10000056_CFlux_Q4.2_slc_fourier_plot_0to100.png", :short_fourier_path => "kic10000056_CFlux_Q4.2_slc_fourier_plot_0to24.png" }]
    end

    def create_pdf
      Prawn::Document.generate(full_output_filename, :page_layout => :portrait, :margin => 5, :skip_page_creation => false) do
        @page_data.each do |observation|
          start_new_page

          image observation[:lightcurve_path], :at => [0,750], :width => 580
          image observation[:short_fourier_path], :at => [0, 560], :width => 580
          image observation[:long_fourier_path], :at => [0, 360], :width => 580

          font_size 20 { draw_text "#{observation[:cycle]}", :at => [5, 760] }

          star_metadata = @star_metadata[observation[:kic_number]]

          draw_text "log g \t = #{star_metadata[:log_g]}", :at => [420, 770]
          draw_text "[Fe/H] = #{star_metadata[:feh]}", :at => [420, 755]
          draw_text "t_eff \t = #{star_metadata[:t_eff]}", :at => [520, 770]
          draw_text "radius = #{star_metadata[:radius]}", :at => [520, 755]
        end

        number_pages "page <page> of <total>", [bounds.right - 80, 0] # must go at end to number all pages
      end
    end
  end
end
