require 'spec_helper'

describe Array do
  describe "to hash" do
    it "should map to correct keys and values" do
      [["foo", "bar"], ["something", "nothing"]].to_hash.should == { :foo => "bar", :something => "nothing" }
    end

    it "should make keys lower case" do
      [["FOO", "bar"]].to_hash.should == { :foo => "bar" }
    end

    it "should replace spaces in keys with underscores" do
      [["FOO FOO", "bar"]].to_hash.should == { :foo_foo => "bar" }
    end
  end
end

describe Float do
  describe "should round to" do
    it "a float" do
      Math::PI.round_to.should be_instance_of(Float)
    end

    it "zero decimal places by default" do
      Math::PI.round_to.should == 3.0
    end

    it "a specified number of decimal places" do
      Math::PI.round_to(2).should == 3.14
    end
  end
end

describe Enumerable do
  let(:test_array) { [1,2,3,4,5,6,7,8,9] }

  describe '#advanced_slice' do
    it 'should take a block and slice where the block returns truthy values' do
      test_array.advanced_slice do |element|
        [1,4,7].include? element
      end.should == [[1,2,3], [4,5,6], [7,8,9]]
    end
  end

  describe '#advanced_slice_with_index' do
    it 'should take a block and slice where the block returns truthy values' do
      test_array.advanced_slice_with_index do |element, index|
        index % 3 == 0
      end.should == [[1,2,3], [4,5,6], [7,8,9]]
    end
  end

  describe "#advanced_slice_splitters" do
    it "should contain sensible block return values as split points" do
      test_array.advanced_slice_splitters do |element, index|
        index % 3 == 0
      end.should == [true, false, false, true, false, false, true, false, false]
    end
  end

  describe "#split_points" do
    it "should contain indicies where the splitters are truthy" do
      def test_array.advanced_slice_splitters
        [true, false, false, true, :foo, nil, true, false, false]
      end

      test_array.split_points.should == [0, 3, 4, 6]
    end
  end
end
