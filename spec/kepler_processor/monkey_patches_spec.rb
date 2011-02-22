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
