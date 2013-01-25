require "spec_helper"

module SpanReport::Process

  describe Report do
    let(:report) { Report.new }
    let(:logformat) { SpanReport::Model::Logformat.instance }

    before(:all) do
      logformat.load_xml("config/LogFormat_100.xml")
    end

    context "add one data" do
 

      it "should be empty when the data is not relate" do
        report = Report.new
        logdata = "0,100,58095305:0,0,,3,;"

        report.add_logdata logdata
        report.get_kpi_value("RecordId").should be_empty

        report.reg_iename "RecordId1", "RecordId1"
        report.add_logdata logdata
        report.get_kpi_value("RecordId").should be_empty
      end

      it "should be the correct max value when the data is relate" do
        report = Report.new
        logdata = "0,100,58095305:0,0,,3,;"
        logdata1 = "0,100,58095305:1,0,,3,;"
        logdata2 = "0,101,58095305:1,0,,3,;"
        config_datas = ["record", "", "max", "RecordId", "", ""]
        counter_item = SpanReport::Model::CounterItem.new config_datas

        report.reg_counter_item counter_item
        report.add_logdata logdata
        report.get_kpi_value("record").should == 0

        report.add_logdata logdata1
        report.get_kpi_value("record").should == 1 

        report.add_logdata logdata2
        report.get_kpi_value("record").should == 1 
      end

      it "should be the correct min value when the data is relate" do
        report = Report.new
        logdata = "0,100,58095305:0,0,,3,;"
        logdata1 = "0,100,58095305:1,0,,3,;"
        logdata2 = "0,101,58095305:1,0,,3,;"
        config_datas = ["record", "", "min", "RecordId", "", ""]
        counter_item = SpanReport::Model::CounterItem.new config_datas

        report.reg_counter_item counter_item
        report.add_logdata logdata
        report.get_kpi_value("record").should == 0

        report.add_logdata logdata1
        report.get_kpi_value("record").should == 0

        report.add_logdata logdata2
        report.get_kpi_value("record").should == 0
      end

      it "should be the correct count value when the data is relate" do
        report = Report.new
        logdata = "0,100,58095305:0,0,,3,;"
        logdata1 = "0,100,58095305:1,0,,3,;"
        logdata2 = "0,101,58095305:1,0,,3,;"
        config_datas = ["record", "", "count", "RecordId", "", ""]
        counter_item = SpanReport::Model::CounterItem.new config_datas

        report.reg_counter_item counter_item
        report.add_logdata logdata
        report.get_kpi_value("record").should == 1

        report.add_logdata logdata1
        report.get_kpi_value("record").should == 2

        report.add_logdata logdata2
        report.get_kpi_value("record").should == 2
      end

      it "should be the correct avg value when the data is relate" do
        report = Report.new
        logdata = "0,100,58095305:0,0,,3,;"
        logdata1 = "0,100,58095305:1,0,,3,;"
        logdata2 = "0,101,58095305:1,0,,3,;"
        config_datas = ["record", "", "avg", "RecordId", "", ""]
        counter_item = SpanReport::Model::CounterItem.new config_datas

        report.reg_counter_item counter_item
        report.add_logdata logdata
        report.get_kpi_value("record").should == 0

        report.add_logdata logdata1
        report.get_kpi_value("record").should == 0.5

        report.add_logdata logdata2
        report.get_kpi_value("record").should == 0.5
      end

      it "should be the correct recent value when the data is relate" do
        report = Report.new
        logdata = "0,100,58095305:0,0,,3,;"
        logdata1 = "0,100,58095305:1,0,,3,;"
        logdata2 = "0,101,58095305:1,0,,3,;"
        config_datas = ["record", "", "recent", "RecordId", "", ""]
        counter_item = SpanReport::Model::CounterItem.new config_datas

        report.reg_counter_item counter_item
        report.add_logdata logdata
        report.get_kpi_value("record").should == "0"

        report.add_logdata logdata1
        report.get_kpi_value("record").should == "1"

        report.add_logdata logdata2
        report.get_kpi_value("record").should == "1"
      end
    end
  end
end
