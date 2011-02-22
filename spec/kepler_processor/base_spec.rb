require 'spec_helper'

describe KeplerProcessor::Base do
  it "should assign options to an instance variable" do
    options = { :foo => :bar }
    KeplerProcessor::Base.new(options).instance_variable_get(:"@options").should == options
  end

  describe "when running" do
    it "should take a runner class as an argument to run" do
      pending
    end

    it "should run for each input filepath provided" do
      pending
    end

    it "should rescue FileExistsError and log an appropriate message" do
      pending
    end

    it "should rescue other exceptions and log the exception message" do
      pending
    end
  end
end
