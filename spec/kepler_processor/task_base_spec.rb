require 'spec_helper'

module KeplerProcessor
  describe TaskBase do

    before(:each) { LOGGER ||= mock('logger').as_null_object }

    describe "an instance" do
      let(:file_paths) { %w{somepath someotherpath} }
      let(:options) { { :input_paths => file_paths } }
      subject { TaskBase.new options }

      it "should assign options to an instance variable" do
        TaskBase.new(options).instance_variable_get(:"@options").should == options
      end

      describe "when executing" do
        class SomeClass; end

        let(:amock) { mock('someclass', :full_output_filename => "something").as_null_object }
        let(:amock2) { mock('someclass2', :full_output_filename => "something2").as_null_object }

        it "should take an input file processor class as an argument to execute" do
          SomeClass.should_receive(:new).at_least(:once)
          subject.execute! SomeClass
        end

        it "should execute for each input filepath provided" do
          SomeClass.should_receive(:new).with(file_paths[0], options).ordered.and_return(amock)
          amock.should_receive(:execute!).ordered
          SomeClass.should_receive(:new).with(file_paths[1], options).ordered.and_return(amock2)
          amock2.should_receive(:execute!).ordered
          subject.execute! SomeClass
        end

        it "should rescue FileExistsError and log an appropriate message" do
          SomeClass.should_receive(:new).with(file_paths[0], options).and_return(amock)
          SomeClass.should_receive(:new).with(file_paths[1], options).and_return(amock2)
          amock.should_receive(:execute!).and_raise(KeplerProcessor::FileExistsError)
          amock2.should_receive(:execute!)
          amock.should_receive(:full_output_filename).and_return("something")
          LOGGER.should_receive(:info).with("Your output file (something) already exists, please remove it first (or something).")
          LOGGER.should_not_receive(:info).with("Your output file (something2) already exists, please remove it first (or something).")
          subject.execute! SomeClass
        end

        it "should rescue other exceptions and log the exception message" do
          SomeClass.should_receive(:new).with(file_paths[0], options).and_return(amock)
          SomeClass.should_receive(:new).with(file_paths[1], options).and_return(amock2)
          amock.should_receive(:execute!).and_raise(StandardError.new("somerandomstring"))
          LOGGER.should_receive(:error).with("somerandomstring")
          subject.execute! SomeClass
        end
      end
    end
  end
end
