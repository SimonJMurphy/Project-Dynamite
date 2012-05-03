class Array
  def to_hash
    # create an empty hash with inject. The key is made lower case and spaces swapped to underscore.
    self.inject({}) do |accumulator, element|
      accumulator[element[0].downcase.gsub(" ", "_").to_sym] = element[1].to_s.gsub(" ", "").strip
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

module Enumerable

  def sum
    self.inject(0) { |acc,i| acc + i }
  end

  def mean
    self.sum / self.length.to_f
  end

  def sample_variance
    avg = self.mean
    sum = self.inject(0) { |acc,i| acc + (i - avg) ** 2 }
    1 / (self.length.to_f * sum)
  end

  def standard_deviation
    Math.sqrt self.sample_variance
  end

  def advanced_slice(&block)
    advanced_slice_with_index &block
  end

  def advanced_slice_with_index(&block)
    [].tap do |slices|
      sp = split_points &block
      each_with_index do |element, index|
        slices << [] if sp.include?(index) || index == 0
        slices.last << element
      end
    end
  end

  def advanced_slice_splitters
    [].tap do |splitters|
      each_with_index do |element, index|
        splitters << yield(element, index)
      end
    end
  end

  def split_points(&block)
    [].tap do |p|
      advanced_slice_splitters(&block).each_with_index do |element, index|
        p << index if element
      end
    end
  end
end
