require 'gsl'
require_relative 'kepler_processor/base.rb'
require_relative 'kepler_processor/convertor.rb'
require_relative 'kepler_processor/transformer.rb'
require_relative 'kepler_processor/merger.rb'

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