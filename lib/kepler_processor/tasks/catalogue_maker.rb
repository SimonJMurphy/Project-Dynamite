require 'prawn'

module KeplerProcessor
  class CatalogueMaker < Base

    def run
      super do
        create_observation_index_hash
      end
    end

    def create_observation_index_hash
      puts @input_data.inspect
      # use this to get kic nums and corresponding parameters
      # one key:value pair for kic num => other values, then one for each of those values representing parameter => corresponding numerical value
    end

    # input_filenames of the form:        kic10000056_CFlux_Q4.2_slc.txt
    # lightcurve_filenames of the form:   kic10000056_CFlux_Q4.2_slc_plot.png
    # fourier_plot_filenames of the form: kic10000056_CFlux_Q4.2_slc_fourier_plot_0to100.png


    # observation_cycle = "kic0123456 Qx slc"
    # log_g = 3.893
    # t_eff = 7364
    # radius = 2.010
    # feh = -0.228
    #
    # file_names = %w(kic11602449_CFlux_Q0_llc_fourier_plot.png kic11602449_CFlux_Q0_slc_fourier_plot.png kic11602449_CFlux_Q1_llc_fourier_plot.png kic11602449_CFlux_Q5_fourier_plot.png)
    #
    # Prawn::Document.generate("Catalogue_Sample.pdf", :page_layout => :portrait, :margin => 5, :skip_page_creation => false) do
    #   lightcurve = "/Users/sjm/code/Project-Dynamite/data/output/wg4_catalogue_images/kic10000056_CFlux_Q4.2_slc_plot.png"
    #   zero_to_24 = "/Users/sjm/code/Project-Dynamite/data/output/wg4_catalogue_images/kic10000056_CFlux_Q4.2_slc_fourier_plot_0to24.png"
    #   zero_to_100 = "/Users/sjm/code/Project-Dynamite/data/output/wg4_catalogue_images/kic10000056_CFlux_Q4.2_slc_fourier_plot_0to100.png"
    #
    #   image lightcurve, :at => [0,750], :width => 580
    #   image zero_to_24, :at => [0, 560], :width => 580
    #   image zero_to_100, :at => [0, 360], :width => 580
    #
    #   font_size 20 do
    #     draw_text "#{observation_cycle}", :at => [5, 760]
    #   end
    #
    #   draw_text "log g \t = #{log_g}", :at => [420, 770]
    #   draw_text "[Fe/H] = #{feh}", :at => [420, 755]
    #   draw_text "t_eff \t = #{t_eff}", :at => [520, 770]
    #   draw_text "radius = #{radius}", :at => [520, 755]
    #
    #   file_names.each do |file|
    #     start_new_page
    #     # file = file_names.first ? text "testing do-looping" : text "testing ruby skilz"
    #     image "#{Prawn::BASEDIR}/lib/prawn/images/#{file}", :at => [5,750], :width => 400
    #   end
    #
    #   number_pages "page <page> of <total>", [bounds.right - 80, 0] # must go at end to number all pages
    # end

    #  create a class, do for filename - find images with predictable image filename and put into document
  end
end
