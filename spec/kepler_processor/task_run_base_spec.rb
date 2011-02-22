require 'spec_helper'

describe KeplerProcessor::TaskRunBase do
  before(:each) do
    @options = { :foo => :bar, :output_path => "output_path" }
    @complete_filename = "/Users/simon/filename.txt"
    @trb = KeplerProcessor::TaskRunBase.new(@complete_filename, @options)
  end

  describe "on instantiation" do
    it "should assign options to an instance variable" do
      @trb.instance_variable_get(:"@options").should == @options
    end

    it "should assign filename to an instance variable" do
      @trb.instance_variable_get(:"@input_filename").should == @complete_filename
    end

    it "should assign filename to an instance variable" do
      @trb.instance_variable_get(:"@input_filename_without_extension").should == "filename"
    end

    it "should assign an empty array for input data to an instance variable" do
      @trb.instance_variable_get(:"@input_data").should == []
    end
  end

  it "should determine correct full output filename" do
    @trb.should_receive(:output_filename).and_return("output_file.txt")
    @trb.full_output_filename.should == "output_path/output_file.txt"
  end

  it "should have a nil output filename by default" do
    @trb.send(:output_filename).should be_nil
  end

  describe "reading in data" do
    it "should read data from the input filename" do
      pending
    end

    it "should split columns by the appropriate delimiter" do
      pending
    end

    it "should convert columns by the appropriate converters" do
      pending
    end

    it "should raise NoDataError if the input file is empty" do
      pending
    end
  end

  it "should split comments (lines starting with a hash) from input data into an instance variable" do
    pending
  end

  it "should get attributes from comment header" do
    pending
  end

  it "should make attributes available publicly" do
    @trb.instance_variable_set(:"@attributes", :foo)
    @trb.attributes.should == :foo
  end

  it "should split out the appropriate columns" do
    pending
  end

  describe "saving output file" do
    it "should not do anything if output filename is nil" do
      pending
    end

    it "should save contents of output data instance variable to correct output file" do
      pending
    end

    it "should save from input data instance variable if no output data has been set" do
      pending
    end

    describe "when force overwriting" do
      it "should not raise FileExistsError" do
        pending
      end
    end

    describe "when not force overwriting" do
      it "should raise FileExistsError if a file exists at the output path" do
        pending
      end
    end

    it "should log with appropriate output file name at the info level" do
      pending
    end
  end
end
