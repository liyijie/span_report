require "spec_helper"

module SpanReport::Process

  describe Report do
    let(:report) { Report.new }

    context "add one data" do
      logdata = "0,100,58095305:0,0,,3,;"

      it "should be empty when the data is not relate" do
        report.add_logdata logdata
        report.get_kpi_value("RecordId").should be_empty

        report.reg_iename "RecordId1", "RecordId"
        report.add_logdata logdata
        report.get_kpi_value("RecordId").should be_empty
      end

      it "should be the correct value when the data is relate" do
        report.reg_iename "RecordId", "RecordId"
        report.add_logdata logdata
        report.get_kpi_value("RecordId").should == "0"
      end
    end

    
  end  
end
