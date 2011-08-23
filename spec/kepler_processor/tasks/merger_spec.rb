require 'spec_helper'

module KeplerProcessor
  class Merger
    describe InputFileProcessor do
      let(:input_filename) { 'kplr001432149-2009131105131_llc_wg4.dat' }

      let(:options) { { :output_path => "somewhere", :file_columns => [1,2,3,4], :merge_ratio => 5 } }

      subject { Merger::InputFileProcessor.new input_filename, options }

      describe "with a short cadence input file" do
        let(:input_filename) { 'data/output/kic9390100_Rflux_Q2.2_slc.txt' }
        its(:std_range) { should == 0.0006811 }
      end

      describe "with a long cadence input file" do
        let(:input_filename) { 'data/output/kic9390100_Rflux_Q2_llc' }
        its(:std_range) { should == 0.020434 }
      end

      def stub_input_data
        subject.input_data = [
          [55002.5095113,	0.00033229443843296735],
          [55002.5101925,	-3.661890775674692e-05],
          [55002.5108736,	1.2209505289462186e-05],
          [55002.5115548,	-0.00010829407831280946],
          [55002.5122359,	0.0002433925402947068],
          [55002.512917,	-6.319699780021892e-05],
          [55002.5135982,	-0.0001010786713031564],
          [55002.5156415,	0.0002785193486900539],
          [55002.5163228,	-5.710536832737034e-06],
          [55002.5170039,	2.892712668867148e-05],
          [55002.517685,	-3.97457756449171e-05],
          [55002.5183662,	-0.00022529723522524137],
          [55002.5190473,	1.4975712641529526e-05],
          [55002.5197286,	-7.245708448877508e-05],
          [55002.5204096,	8.786180207209782e-05],
          [55002.5210907,	0.0002759930676923261],
          [55002.5217718,	-9.614811560609837e-05],
          [55002.522453, 0.0001834871121211279],
          [55002.5231342,	4.9373488394621745e-05],
          [55002.5238153,	3.229473624699608e-05],
          [55002.5244965,	-0.0002024507440516743],
          [55002.5251776,	-0.0001940334945409461],
          [55002.5258586,	-0.00012092092519111475],
          [55002.5265399,	-7.197604297104476e-05],
          [55002.527221, 0.00014655910739591604],
          [55002.5279021,	-0.00011130048374496937],
          [55002.5285833,	0.00010373862895107777],
          [55002.5292644,	4.877211932097225e-05],
          [55002.5299457,	0.000123344],
          [55002.5306268,	7.28E-05]
        ]
      end

      def stub_pad_points
        subject.stub(:pad_points).and_return [
          [55002.5142794,	nil],
          [55002.5149604,	nil]
        ]
      end

      def stub_std_range
        subject.stub(:std_range).and_return(0.0006811)
      end

      describe "#pad_points" do
        before do
          stub_input_data
          stub_std_range
        end

        its(:pad_points) { should have(2).points }

        it "should create the points at the correct time" do
          subject.pad_points.first.first.should == 55002.5142794.round(6)
          subject.pad_points.last.first.should == 55002.5149604.round(6)
        end

        it "should have nil flux values" do
          subject.pad_points.each do |point|
            point[1].should be_nil
          end
        end
      end

      describe "#pad_data" do
        before do
          stub_input_data
          stub_pad_points
          subject.pad_data
        end

        it "should inject padded data inline" do
          subject.input_data[7].should == subject.pad_points[0]
          subject.input_data[8].should == subject.pad_points[1]
        end
      end

      describe "#slice!" do
        before do
          stub_input_data
          stub_std_range
          subject.pad_data
        end

        it "should process the correct slices" do
          subject.should_receive(:process_slice).with(subject.input_data[0,5]).once.ordered
          subject.should_receive(:process_slice).with(subject.input_data[5,5]).once.ordered
          subject.should_receive(:process_slice).with(subject.input_data[10,5]).once.ordered
          subject.should_receive(:process_slice).with(subject.input_data[15,5]).once.ordered
          subject.should_receive(:process_slice).with(subject.input_data[20,5]).once.ordered
          subject.should_receive(:process_slice).with(subject.input_data[25,5]).once.ordered
          subject.should_receive(:process_slice).with(subject.input_data[30,2]).once.ordered
          subject.slice!
        end

        it "should produce the desired output data" do
          subject.slice!
          subject.output_data.should == [
            [55002.51087, 8.85967E-05],
            [55002.51769, -4.53701E-05],
            [55002.52109, 7.57474E-05],
            [55002.5245,  -8.71474E-05],
            [55002.5279,  2.31587E-05]
          ]
        end
      end

      describe "#process_slice" do
        before do
          subject.output_data = []
          subject.process_slice slice
        end

        describe "with padded points" do
          let :slice do
            [
              [55002.512917,  -6.319699780021892e-05],
              [55002.5135982, -0.0001010786713031564],
              [55002.5142794, nil],
              [55002.5149604, nil],
              [55002.5156415, 0.0002785193486900539]
            ]
          end

          it "should delete points with nil flux values" do
            slice.should have(3).points
          end
        end

        describe "with a full slice" do
          let :slice do
            [
              [55002.5095113,	0.00033229443843296735],
              [55002.5101925,	-3.661890775674692e-05],
              [55002.5108736,	1.2209505289462186e-05],
              [55002.5115548,	-0.00010829407831280946],
              [55002.5122359,	0.0002433925402947068]
            ]
          end

          it "should add points to the output data" do
            subject.output_data.should have(1).point
            subject.output_data.first.should == [55002.51087,	0.0000885967]
          end
        end

        describe "with too few points" do
          let :slice do
            [
              [55002.512917,  -6.319699780021892e-05],
              [55002.5135982, -0.0001010786713031564],
              [55002.5135992, -0.0001010786713031564],
              [55002.5156415, 0.0002785193486900539]
            ]
          end

          it "does not add anything to the output data" do
            subject.output_data.should be_empty
          end
        end
      end
    end
  end
end
