require "spec_helper"

module SpanReport::Process

  describe Report do
    let(:report) { Report.new }
    let(:logformat) { SpanReport::Model::Logformat.instance }

    before(:all) do
      logformat.load_xml("config/LogFormat_100.xml")
    end

    context "add one data with no condition" do

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
        config_datas_max = ["record_max", "", "max", "RecordId", "", ""]
        counter_item = SpanReport::Model::CounterItem.new config_datas
        counter_item_max = SpanReport::Model::CounterItem.new config_datas_max

        report.reg_counter_item counter_item
        report.reg_counter_item counter_item_max     
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

    context "have self condition" do
      it "should be the correct count value when the data is relate" do
        report = Report.new
        logdata = "0,100,58095305:0,0,,3,;"
        logdata1 = "0,100,58095305:1,0,,3,;"
        logdata2 = "0,101,58095305:1,0,,3,;"
        config_datas = ["record", "", "count", "RecordId", "equal", "1"]
        config_datas_max = ["record_max", "", "max", "RecordId", "", ""]
        counter_item = SpanReport::Model::CounterItem.new config_datas
        counter_item_max = SpanReport::Model::CounterItem.new config_datas_max

        report.reg_counter_item counter_item
        report.reg_counter_item counter_item_max     
        report.add_logdata logdata
        report.get_kpi_value("record").should == ""

        report.add_logdata logdata1
        report.get_kpi_value("record").should == 1

        report.add_logdata logdata2
        report.get_kpi_value("record").should == 1
      end
    end

    context "have array and section condition" do
      it "has the mcs data the log id is 1277, condition is rsrp the log id is 1189" do
        report = Report.new

        logdata_mcs = "0,1277,58095305:1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,
        22,23,24,25,26,27,28,29,30,31,32,33,34"

        logdata_rsrp_90 = "0,1189,58095306:,,,,,,90,,,"
        logdata_rsrp_100= "0,1189,58095306:,,,,,,100,,,"

        mcs_condition1_1 = ["MCS_UL_0[0]", "", "sum", "TDDLTE_MCS_DL_Code0_MCS_Count_0", "", "", 
                 "TDDLTE_L1_measurement_Serving_Cell_Measurement_RSRP", "range", "[90,100)"]
        mcs_condition1_2 = ["MCS_UL_0[1]", "", "sum", "TDDLTE_MCS_DL_Code0_MCS_Count_0", "", "", 
                 "TDDLTE_L1_measurement_Serving_Cell_Measurement_RSRP", "range", "[100,110)"]
        report.reg_counter_item SpanReport::Model::CounterItem.new mcs_condition1_1
        report.reg_counter_item SpanReport::Model::CounterItem.new mcs_condition1_2
        mcs_condition2_1 = ["MCS_UL_1[0]", "", "sum", "TDDLTE_MCS_DL_Code0_MCS_Count_1", "", "", 
                 "TDDLTE_L1_measurement_Serving_Cell_Measurement_RSRP", "range", "[90,100)"]
        mcs_condition2_2 = ["MCS_UL_1[1]", "", "sum", "TDDLTE_MCS_DL_Code0_MCS_Count_1", "", "", 
         "TDDLTE_L1_measurement_Serving_Cell_Measurement_RSRP", "range", "[100,110)"]

        report.reg_counter_item SpanReport::Model::CounterItem.new mcs_condition2_1
        report.reg_counter_item SpanReport::Model::CounterItem.new mcs_condition2_2

        report.add_logdata logdata_mcs
        report.get_kpi_value("MCS_UL_0[0]").should == ""

        report.add_logdata logdata_rsrp_90
        report.add_logdata logdata_mcs
        report.get_kpi_value("MCS_UL_0[0]").should == 1
        report.get_kpi_value("MCS_UL_0[1]").should == ""
        report.get_kpi_value("MCS_UL_1[0]").should == 2
        report.get_kpi_value("MCS_UL_1[1]").should == ""

        report.add_logdata logdata_rsrp_100
        report.add_logdata logdata_mcs
        report.get_kpi_value("MCS_UL_0[0]").should == 1
        report.get_kpi_value("MCS_UL_0[1]").should == 1
        report.get_kpi_value("MCS_UL_1[0]").should == 2
        report.get_kpi_value("MCS_UL_1[1]").should == 2
      end
    end

    context "test the file group static" do
      it "should be static both with file group or not" do
        report = Report.new
        logdata = "0,100,58095305:0,0,,3,;"
        logdata1 = "0,100,58095305:1,0,,3,;"
        logdata2 = "0,100,58095305:2,0,,3,;"
        config_datas = ["record", "", "sum", "RecordId", "", ""]
        counter_item = SpanReport::Model::CounterItem.new config_datas

        report.reg_counter_item counter_item
        report.add_logdata logdata, "cell1-1"
        report.get_kpi_value("record").should == 0
        report.get_kpi_value("cell1-1#record").should == 0
        report.get_kpi_value("cell1-2#record").should == ""

        report.add_logdata logdata1
        report.get_kpi_value("record").should == 1
        report.get_kpi_value("cell1-1#record").should == 0
        report.get_kpi_value("cell1-2#record").should == ""

        report.add_logdata logdata2, "cell1-2"
        report.get_kpi_value("record").should == 3
        report.get_kpi_value("cell1-1#record").should == 0
        report.get_kpi_value("cell1-2#record").should == 2

        report.add_logdata logdata2, "cell1-2"
        report.get_kpi_value("record").should == 5
        report.get_kpi_value("cell1-1#record").should == 0
        report.get_kpi_value("cell1-2#record").should == 4
      end
    end
  end
end
