require 'spec_helper'

describe KeplerProcessor::Appender do
  # Future features:
  # reinsert the partitioned comments, but change the 'season' parameter's value to read 'multiple' or something more specific if possible
  # could ask for user input for 'season' parameter

  before(:each) do
    LOGGER ||= mock('logger').as_null_object
    @input_filenames = %w{kplr001432149-2009131105131_llc_wg4.dat kplr001436149-2009131105131_llc_wg4.dat}
    @options = { :input_paths => @input_filenames, :output_path => "somewhere" }
    @app = KeplerProcessor::Appender.new(@options)
  end

  it "creates a runner object for each specified input file" do
    KeplerProcessor::Appender::Run.should_receive(:new).with(@input_filenames[0], @options)
    KeplerProcessor::Appender::Run.should_receive(:new).with(@input_filenames[1], @options)
    @app.send :get_input_files
  end

  it "collects an array of runner objects for all specified input files" do
    @app.send :get_input_files
    runners = @app.instance_variable_get(:"@runners")
    runners.should be_instance_of(Array)
    runners.size.should == 2
    runners.each { |runner| runner.should be_instance_of(KeplerProcessor::Appender::Run) }
  end

  it "should raise an error if there are fewer than two files" do
    @input_filenames = %w{kplr001432149-2009131105131_llc_wg4.dat}
    @options = { :input_paths => @input_filenames, :output_path => "somewhere" }
    lambda { KeplerProcessor::Appender.new(@options).send :check_input_file_count }.should raise_error(RuntimeError, /Two or more input files required/)
  end

  it "should not raise an error if there are two or more files" do
    lambda { @app.send :check_input_file_count }.should_not raise_error(RuntimeError, /Two or more input files required/)
  end

  it "should not raise an error if files have the same kic number" do
    runners = [1,2].map { mock('runner', :attributes => { :kic_number => 100}) }
    @app.instance_variable_set(:"@runners", runners)
    lambda { @app.send :check_consistent_kic_number }.should_not raise_error(RuntimeError, /All files must be for the same star/)
  end

  it "should raise an error if files do not have the same kic number" do
    runners = [1,2].map { |i| mock('runner', :attributes => { :kic_number => i}) }
    @app.instance_variable_set(:"@runners", runners)
    lambda { @app.send :check_consistent_kic_number }.should raise_error(RuntimeError, /All files must be for the same star/)
  end
  it "should collate input file data" do
    runners = [1,2].map { mock('runner', :input_data => [[1,2,3,4], [1,2,3,4]]) }
    @app.instance_variable_set(:"@runners", runners)
    @app.send :collate_input_data
    @app.instance_variable_get(:"@output_data").should == [[1,2,3,4], [1,2,3,4], [1,2,3,4], [1,2,3,4]]
  end

  it "should figure out its output filename" do
    runners = [1,2].map { |i| mock('runner', :input_filename_without_path => @input_filenames.first, :attributes => {:season => "Q#{i}"}) }
    @app.instance_variable_set(:"@runners", runners)
    @app.send(:output_filename).should == "kplr001432149-appended_Q1-Q2_llc_wg4.dat"
  end

  it "should save output data to correct output file" do
    output_filename = "someoutputfilename"
    @app.stub(:output_filename).and_return(output_filename)
    CSV.should_receive(:open).with("#{@options[:output_path]}/#{output_filename}", "a+", {:col_sep=>"\t"})
    @app.send :save!
  end




  end
end

describe KeplerProcessor::Appender::Run do
  it "should inherit from TaskRunBase" do
    KeplerProcessor::Appender::Run.should < KeplerProcessor::TaskRunBase
  end

  it "should not have an output filename" do
    KeplerProcessor::Appender::Run.new("someinputfilename").output_filename.should be_nil
  end
end
