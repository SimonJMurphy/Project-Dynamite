require 'gsl'
require_relative 'kepler_processor/base.rb'
require_relative 'kepler_processor/convertor.rb'
require_relative 'kepler_processor/transformer.rb'

module KeplerProcessor
  class FileExistsError < StandardError; end
  class NoDataError < StandardError; end
end

class Array
  def to_hash
    self.inject({}) { |accumulator, element| accumulator[element[0].downcase.gsub(" ", "_").to_sym] = element[1].gsub(" ", "").strip; accumulator }
    # creating an empty hash with inject. The key is made lower case and spaces swapped to underscore.
  end
end