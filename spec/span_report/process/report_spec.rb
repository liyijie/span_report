require "spec_helper"

module SpanReport::Process

  describe Report do
    let(:report) { Report.new }
    let(:logformat) { SpanReport::Model::Logformat.instance }

    before(:all) do
      logformat.load_xml("config/LogFormat_100.xml")
    end

    before(:each) do
      report = Report.new
    end

    context "add one data" do

      it "should be empty when the data is not relate" do
        logdata = "0,100,58095305:0,0,,3,;"

        report.add_logdata logdata
        report.get_kpi_value("RecordId").should be_empty

        report.reg_iename "RecordId1", "RecordId1"
        report.add_logdata logdata
        report.get_kpi_value("RecordId").should be_empty
      end

      it "should be the correct value when the data is relate" do
        logdata = "0,100,58095305:0,0,,3,;"
        logdata1 = "0,100,58095305:1,0,,3,;"

        report.reg_iename "RecordId", "RecordId"
        report.add_logdata logdata
        report.get_kpi_value("RecordId").should == "0"

        report.add_logdata logdata1
        report.get_kpi_value("RecordId").should == "1"      

      end
    end


  end  
end
