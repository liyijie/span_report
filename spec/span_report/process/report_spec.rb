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
        report.get_kpi_value("RecordId", "max").should be_empty

        report.reg_iename "RecordId1", "RecordId1"
        report.add_logdata logdata
        report.get_kpi_value("RecordId", "max").should be_empty
      end

      it "should be the correct value when the data is relate" do
        logdata = "0,100,58095305:0,0,,3,;"
        logdata1 = "0,100,58095305:1,0,,3,;"
        config_datas = ["record", "", "max", "RecordId", "", ""]
        counter_item = SpanReport::Model::CounterItem.new config_datas

        report.reg_counter_item counter_item
        report.add_logdata logdata
        report.get_kpi_value("record", "max").should == 0

        report.add_logdata logdata1
        report.get_kpi_value("record", "max").should == 1 
        report.get_kpi_value("record", "avg").should == 0.5 
      end
    end
  end  

  describe ReportValue do
    let(:reportvalue) { ReportValue.new }

    context "add empty value" do
      it "should be nil when reportvalue is new & add nil data" do
        reportvalue.add_value nil
        reportvalue.max.should be_nil
        reportvalue.min.should be_nil
        reportvalue.count.should == 0
        reportvalue.sum.should == 0.0
        reportvalue.avg.should == "N/A"
        reportvalue.recent.should be_nil
      end

      it "should be nil when reportvalue is new & add empty data" do
        reportvalue.add_value ""
        reportvalue.max.should be_nil
        reportvalue.min.should be_nil
        reportvalue.count.should == 0
        reportvalue.sum.should == 0.0
        reportvalue.recent.should be_nil
      end

      it "should remain lastest value when add nil data" do
        reportvalue.max = 5
        reportvalue.min = 1
        reportvalue.count = 8
        reportvalue.sum = 64
        reportvalue.recent = 9

        reportvalue.add_value nil
        reportvalue.max.should == 5
        reportvalue.min.should == 1
        reportvalue.count.should == 8
        reportvalue.sum.should == 64
        reportvalue.recent.should == 9
      end

      it "should remain lastest value when add empty data" do
        reportvalue.max = 5
        reportvalue.min = 1
        reportvalue.count = 8
        reportvalue.sum = 64
        reportvalue.recent = 9

        reportvalue.add_value ""
        reportvalue.max.should == 5
        reportvalue.min.should == 1
        reportvalue.count.should == 8
        reportvalue.sum.should == 64
        reportvalue.recent.should == 9
      end
    end

    context "add one correct data" do
      it "should be the data when reportdata is new" do
        reportvalue.add_value "9"
        reportvalue.max.should == 9
        reportvalue.min.should == 9
        reportvalue.count.should == 1
        reportvalue.sum.should == 9
        reportvalue.recent.should == 9
      end

      it "should max" do
        reportvalue.max = 6
        reportvalue.add_value "8"
        reportvalue.max.should == 8
        reportvalue.add_value "5"
        reportvalue.max.should == 8
      end

      it "should min" do
        reportvalue.min = 6
        reportvalue.add_value "5"
        reportvalue.min.should == 5
        reportvalue.add_value "7"
        reportvalue.min.should == 5
      end

      it "should avg" do
        reportvalue.count = 5
        reportvalue.sum = 40
        reportvalue.add_value "5"
        reportvalue.avg.should == 45.0/6
      end

      it "should recent" do
        reportvalue.recent = 6
        reportvalue.add_value "10"
        reportvalue.recent.should == 10
      end

      it "should return the right value by mode" do
        reportvalue.add_value "10"
        reportvalue.getvalue("max").should == 10
        reportvalue.getvalue("min").should == 10
        reportvalue.getvalue("sum").should == 10
        reportvalue.getvalue("avg").should == 10
      end
    end


  end
end
