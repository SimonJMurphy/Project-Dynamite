module KeplerProcessor
  class Inspector < MultifileTaskBase

    attr_accessor :output_data
    include Saveable

    def execute!
      super do
        check_consistent_kic_number
        sort_runners_by_season
        collate_input_data
        show_me_the_droids_I_am_looking_for
      end
    end

    private

    def check_consistent_kic_number
      raise RuntimeError, "All files must be for the same star" if @runners.map { |r| r.attributes[:kic_number] }.uniq.count > 1
    end

    def sort_runners_by_season
      @runners.sort! { |a,b| a.attributes[:season] <=> b.attributes[:season] }
    end

    def collate_input_data
      @output_data = @runners.map { |runner| runner.input_data }.flatten 1
    end

    def time_span
      (@output_data.last.first - @output_data.first.first).round_to(3)
    end

    def std_range
      # the time gap between consecutive SC points is just over 0.00068 (0.0006811) and for LC data is just greater than 0.02
      @runners.first.attributes[:cadence] == "slc" ? 0.0006811 : 0.020434
    end

    def duty_cycle
      (100 * @output_data.size / (time_span / std_range)).round_to(3)
    end
    
    def show_me_the_droids_I_am_looking_for
      if @runners.count == 1
        puts "\nFor #{@runners.first.attributes[:kic_number]} #{@runners.first.attributes[:season]}, the time span is #{time_span} days and the duty cycle is #{duty_cycle} %.\n\n"
      else
        puts "\nFor #{@runners.first.attributes[:kic_number]}, the time span is #{time_span} days (from #{@runners.first.attributes[:season]} to #{@runners.last.attributes[:season]}) and the duty cycle is #{duty_cycle} %.\n\n"
      end
    end

  end
end
