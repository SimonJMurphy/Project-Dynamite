require 'prawn'

module KeplerProcessor
  class CatalogueMaker < TaskBase

    def execute!
      @options[:column_delimiter] = ","
      @options[:file_columns] = (0..8).to_a
      @options[:column_converters] = [:integer, :float, :float, :float, :float, :float, :float, :float, :float]
      super InputFileProcessor
    end

    class InputFileProcessor < InputFileProcessorBase

      def execute!
        super do
          @errors = []
          @txt_save = false
          create_star_metadata_hash
          create_observation_index
          sort_observation_index_by_kic_number
          create_pdf
          print_errors
        end
      end

      def create_star_metadata_hash
        @star_metadata = {}
        @input_data.delete_if { |line| line.empty? }
        @input_data.each do |star|
          @star_metadata[star[0].to_i] = { :magnitude => star[3], :t_eff => star[4], :radius => star[5], :log_g => star[6], :feh => star[7], :contamination => star[8] }
        end
      end

      def create_observation_index
        @observation_index = @input_data.map do |observation|
          @working_group = @input_filename_without_path.split("_").first
          @catalogue_images_path = "/#{@input_filename.split("/")[1 ... -1].join("/")}/#{@working_group}_catalogue_images/"
          kic_number, cadence, season = observation
          cadence = cadence == "SC" ? "slc" : "llc"
          flux_type = "MAP"
          hash = { :kic_number => kic_number, :cadence => cadence, :season => season, :cycle => "kic#{kic_number} #{season} #{cadence} #{flux_type}", :lightcurve_path => "#{@catalogue_images_path}kic#{kic_number}_#{flux_type}_#{season}_#{cadence}_plot.png", :short_fourier_path => "#{@catalogue_images_path}kic#{kic_number}_#{flux_type}_#{season}_#{cadence}_fourier_plot_0to24.png" }
          hash[:long_fourier_path] = "#{@catalogue_images_path}kic#{kic_number}_#{flux_type}_#{season}_#{cadence}_fourier_plot_0to100.png" if cadence == "slc"
          season.insert(1, "0") if season.split("Q").last.to_i < 10 # so that Q10 comes after Q9 (Q09) rather than between Q1 & Q2
          hash
        end
      end

      def sort_observation_index_by_kic_number
        @observation_index.sort! do |a, b|
          comparison_result = a[:kic_number] <=> b[:kic_number]
          comparison_result = a[:season] <=> b[:season] if comparison_result == 0
          comparison_result
        end
      end

      # input_filenames of the form:        kic10000056_LS_Q4.2_slc.txt
      # lightcurve_filenames of the form:   kic10000056_LS_Q4.2_slc_plot.png
      # fourier_plot_filenames of the form: kic10000056_LS_Q4.2_slc_fourier_plot_0to100.png

      def create_pdf
        observation_index = @observation_index
        star_metadata = @star_metadata
        errors = @errors
        Prawn::Document.generate(full_output_filename, :page_layout => :portrait, :margin => 5, :skip_page_creation => false) do
          observation_index.each do |observation|
            start_new_page

            begin
              image observation[:lightcurve_path], :at => [0,750], :width => 580
            rescue ArgumentError => e
              errors << e
            end

            begin
              image observation[:short_fourier_path], :at => [0, 560], :width => 580
            rescue ArgumentError => e
              errors << e
            end

            begin
              image observation[:long_fourier_path], :at => [0, 360], :width => 580 if observation[:long_fourier_path]
            rescue ArgumentError => e
              errors << e
            end

            font_size(20) { draw_text observation[:cycle], :at => [5, 760] }

            if metadata = star_metadata[observation[:kic_number]]
              draw_text "log g \t = #{metadata[:log_g]}", :at => [420, 770]
              draw_text "[Fe/H] = #{metadata[:feh]}", :at => [420, 755]
              draw_text "Teff \t = #{metadata[:t_eff]}", :at => [520, 770]
              draw_text "radius = #{metadata[:radius]}", :at => [520, 755]
              draw_text "Kp mag \t = #{metadata[:magnitude]}", :at => [300, 770]
              draw_text "contam. \t = #{metadata[:contamination]}", :at => [300, 755]
            end
          end
        end
      end

      def print_errors
        return if @errors.empty?
        puts "The following errors occurred:"
        @errors.each do |e|
          puts "  * #{e.message} (#{e.class})"
        end
      end

      def output_filename
        "#{@working_group}_catalogue.pdf"
      end
    end
  end
end
