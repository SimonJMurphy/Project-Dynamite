require 'gsl'
require 'gnuplot'

require_relative 'kepler_processor/base.rb'
require_relative 'kepler_processor/convertor.rb'
require_relative 'kepler_processor/fourier.rb'
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
      accumulator[element[0].downcase.gsub(" ", "_").to_sym] = element[1].gsub(" ", "").strip; accumulator
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
