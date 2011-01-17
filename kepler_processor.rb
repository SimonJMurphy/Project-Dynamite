require 'gsl'

require_relative 'kepler_processor/base.rb'
require_relative 'kepler_processor/computor.rb'
require_relative 'kepler_processor/convertor.rb'
require_relative 'kepler_processor/fourier.rb'
require_relative 'kepler_processor/light_curve_plotter.rb'
require_relative 'kepler_processor/merger.rb'
require_relative 'kepler_processor/transformer.rb'

module KeplerProcessor
  class FileExistsError < StandardError; end
  class NoDataError < StandardError; end
end

class Array
  def to_hash
    # create an empty hash with inject. The key is made lower case and spaces swapped to underscore.
    self.inject({}) do |accumulator, element|
      accumulator[element[0].downcase.gsub(" ", "_").to_sym] = element[1].gsub(" ", "").strip
      accumulator
    end
  end
end

class Float
  SECONDS_PER_DAY = 24*60*60
  def round_to n = 0 # rounds to specified number of d.p.
    (self * 10**n).round / 10.0**n
  end

  def freq_to_per_day
    self / SECONDS_PER_DAY
  end
end

class IntervalArray < Array
  attr_reader :range, :step_size
  def initialize(range, step_size = 1)
    super()
    @range = range
    @step_size = step_size
    regenerate
  end

  def range=(range)
    @range = range
    regenerate
  end

  def step_size=(step_size)
    @step_size = step_size
    regenerate
  end

  private
    def regenerate
      clear
      self << @range.min
      num_elements = (@range.count - 1) / @step_size
      while count <= num_elements
        self << last + @step_size
      end
    end
end

class Range
  def in_steps_of(n = 1)
    IntervalArray.new self, n
  end
end
