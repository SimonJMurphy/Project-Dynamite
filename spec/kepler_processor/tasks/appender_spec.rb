require 'spec_helper'

module KeplerProcessor
  describe Appender do
    # Future features:
    # reinsert the partitioned comments, but change the 'season' parameter's value to read 'multiple' or something more specific if possible
    # could ask for user input for 'season' parameter

    let(:input_filenames) { %w{kplr001432149-2009131105131_llc_wg4.dat kplr001436149-2009131105131_llc_wg4.dat} }

    let(:options) { { :input_paths => input_filenames, :output_path => "somewhere", :file_columns => [1,2,3,4] } }

    subject { Appender.new options }

    it "creates a runner object for each specified input file" do
      InputFileProcessorBase.should_receive(:new).with(input_filenames[0], options)
      InputFileProcessorBase.should_receive(:new).with(input_filenames[1], options)
      subject.send :get_input_files
    end

    it "collects an array of runner objects for all specified input files" do
      subject.send :get_input_files
      runners = subject.instance_variable_get(:"@runners")
      runners.should be_instance_of(Array)
      runners.size.should == 2
      runners.each { |runner| runner.should be_instance_of(KeplerProcessor::InputFileProcessorBase) }
    end

    it "runs all runners" do
      runners = [1,2].map do
        runner = mock('runner')
        runner.should_receive(:execute!)
        runner
      end
      subject.instance_variable_set(:"@runners", runners)
      subject.send :execute_all_runners
    end

    it "should raise an error if there are fewer than two files" do
      input_filenames = %w{kplr001432149-2009131105131_llc_wg4.dat}
      options = { :input_paths => input_filenames, :output_path => "somewhere" }
      lambda { Appender.new(options).send :check_input_file_count }.should raise_error(RuntimeError, /Two or more input files required/)
    end

    it "should not raise an error if there are two or more files" do
      lambda { subject.send :check_input_file_count }.should_not raise_error(RuntimeError, /Two or more input files required/)
    end

    it "should not raise an error if files have the same kic number" do
      runners = [1,2].map { mock('runner', :attributes => { :kic_number => 100}) }
      subject.instance_variable_set(:"@runners", runners)
      lambda { subject.send :check_consistent_kic_number }.should_not raise_error(RuntimeError, /All files must be for the same star/)
    end

    it "should raise an error if files do not have the same kic number" do
      runners = [1,2].map { |i| mock('runner', :attributes => { :kic_number => i}) }
      subject.instance_variable_set(:"@runners", runners)
      lambda { subject.send :check_consistent_kic_number }.should raise_error(RuntimeError, /All files must be for the same star/)
    end

    it "should sort input files by season" do
      runners = [2,3,1].map { |i| mock('runner', :attributes => {:season => "Q#{i}"}) }
      subject.instance_variable_set(:"@runners", runners)
      subject.send :sort_runners_by_season
      subject.instance_variable_get(:"@runners").map { |r| r.attributes[:season] }.should == %w{Q1 Q2 Q3}
    end

    it "should collate input file data" do
      runners = [1,2].map { mock('runner', :input_data => [[1,2,3,4], [1,2,3,4]]) }
      subject.instance_variable_set(:"@runners", runners)
      subject.send :collate_input_data
      subject.instance_variable_get(:"@output_data").should == [[1,2,3,4], [1,2,3,4], [1,2,3,4], [1,2,3,4]]
    end

    it "should figure out its output filename" do
      runners = [1,2].map { |i| mock('runner', :input_filename_without_path => input_filenames.first, :attributes => {:season => "Q#{i}"}) }
      subject.instance_variable_set(:"@runners", runners)
      subject.send(:output_filename).should == "kplr001432149-appended_Q1-Q2_llc_wg4.dat"
    end

    it "should save output data to correct output file" do
      output_filename = "someoutputfilename"
      subject.stub(:output_filename).and_return(output_filename)
      CSV.should_receive(:open).with("#{options[:output_path]}/#{output_filename}", "a+", {:col_sep=>"\t"})
      subject.send :save!
    end

    describe "should perform full execution" do

      it "in order" do
        subject.should_receive(:check_input_file_count).ordered
        subject.should_receive(:get_input_files).ordered
        subject.should_receive(:execute_all_runners).ordered
        subject.should_receive(:check_consistent_kic_number).ordered
        subject.should_receive(:sort_runners_by_season).ordered
        subject.should_receive(:collate_input_data).ordered
        subject.should_receive(:save!).ordered
        subject.execute!
      end

      it "without errors" do
        example_input_file_contents = [["#", "Kepler", "Asteroseismic", "Data"], ["#", "Working", "Group", 4.0, "Corrected", "data,", "by", "Juan", "Gutierrez-Soto"], ["#", "KIC", "number:", 1432149.0], ["#", "Season:", "Q0"], ["#", "TRF:", 0.0], ["#", "Version:", 3.1, "(4", "October", "2010)"], ["#", "Time", "is", "in", "truncated", "barycentric", "julian", "date"], ["#", "Time", "(days),", "Raw", "Flux,", "Raw", "Flux", "error,", "Corrected", "Flux,", "Corrected", "Flux", "error,", "WG", 4.0, "Corrected", "Flux,", "WG", 4.0, "Corrected", "error"], ["#-----------------------------------------------------------"], [54953.5385117, 756574784.0, 31541.7, 745490304.0, 24308.6, 756574784.0, 31541.7], [54953.5589464, 756351360.0, 31541.0, 744989952.0, 27273.1, 756351360.0, 31541.0], [54953.5793809, 756300672.0, 31540.4, 745161856.0, 27921.0, 756300672.0, 31540.4], [54953.5998157, 756223488.0, 31539.7, 745131264.0, 28616.3, 756223488.0, 31539.7], [54953.6202503, 756059328.0, 31539.1, 744817920.0, 29284.8, 756059328.0, 31539.1], [54953.6406849, 756086784.0, 31538.4, 745027648.0, 28867.8, 756086784.0, 31538.4], [54953.6611195, 755987328.0, 31537.8, 744956096.0, 29047.3, 755987328.0, 31537.8], [54953.6815543, 755932288.0, 31537.2, 744925760.0, 28978.2, 755932288.0, 31537.2], [54953.7019888, 756094208.0, 31536.5, 744905728.0, 28729.0, 756094208.0, 31536.5], [54953.7224235, 756382976.0, 31535.9, 745173184.0, 29816.9, 756382976.0, 31535.9], [54953.7428582, 756595392.0, 31535.2, 745608768.0, 29411.9, 756595392.0, 31535.2], [54953.7632927, 756727680.0, 31534.6, 745744320.0, 30016.8, 756727680.0, 31534.6], [54953.7837274, 756596096.0, 31533.9, 745271808.0, 29175.5, 756596096.0, 31533.9], [54953.804162, 756725376.0, 31533.3, 745768640.0, 30088.2, 756725376.0, 31533.3], [54953.8245967, 756563136.0, 31532.7, 745437440.0, 29767.5, 756563136.0, 31532.7], [54953.8450313, 756250880.0, 31532.0, 744985920.0, 29777.9, 756250880.0, 31532.0], [54953.865466, 756084608.0, 31531.4, 744902528.0, 30125.7, 756084608.0, 31531.4], [54953.8859007, 755698304.0, 31530.7, 744768704.0, 29779.2, 755698304.0, 31530.7], [54953.9063353, 755434816.0, 31530.1, 744392640.0, 30140.9, 755434816.0, 31530.1], [54953.9267699, 755235840.0, 31529.4, 744342464.0, 29458.8, 755235840.0, 31529.4], [54953.9472046, 755063360.0, 31528.8, 744200576.0, 29467.4, 755063360.0, 31528.8]]
        CSV.should_receive(:read).twice do
          Marshal.load Marshal.dump(example_input_file_contents)
        end
        CSV.should_receive(:open)
        lambda { subject.execute! }.should_not raise_error
      end

    end
  end
end
