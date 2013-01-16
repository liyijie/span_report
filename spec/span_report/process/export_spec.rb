require "spec_helper"

module SpanReport::Process

  describe Export do
    
    context "test data_needed? function" do
      let(:export_process) { Export.new }
      let(:logformat) { SpanReport::Model::Logformat.instance }
      before(:each) do
        logformat.load_xml("config/LogFormat_100.xml")  
      end

      logdata = "0,100,58095305:0,0,,3,;"

      it "should return false when the iename is not include" do
        export_process.data_needed?(logdata).should be_false

      end

      it "should return true when the iename is include" do
        export_process.reg_iename "RecordId"
        export_process.data_needed?(logdata).should be_true
      end
      
    end


  end
  
end