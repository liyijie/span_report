require "spec_helper"

module SpanReport::Model
  describe Logformat do
    
    let(:logformat) { Logformat.instance }

    before(:each) do
      logformat.load_xml("config/LogFormat_100.xml")
    end

    context "log group 1002" do
      let(:log_group) { logformat.group_map[1002] }
      it "should have 10 " do
        log_group.size.should == 10
      end

      it "should be Common_Application_email_Email_Send_Data_Size in the [1]" do
        log_group[1].name.should == "Common_Application_email_Email_Send_Data_Size"
      end

      it "should be Common_Application_email_Email_Send_Data_Size from the 1002-1 from item_map" do
        logitem = logformat.item_map["Common_Application_email_Email_Send_Data_Size"]
        logitem.name.should == "Common_Application_email_Email_Send_Data_Size"
        logitem.type.should == "double"
        logitem.group.should == 1002
        logitem.index.should == 1
      end
    end

    context "get log item from ie name" do
      it "should return the correct logitem when the iename is correct" do
        logitem = logformat.get_logitem "TDSCDMA_L1_Procedure_Information_TPC_SS_Information_DL_TPC1"
        logitem.name.should == "TDSCDMA_L1_Procedure_Information_TPC_SS_Information_DL_TPC1"
        logitem.type.should == "double"
        logitem.group.should == 1019
        logitem.index.should == 9
      end

      it "should be nil when the iename is wrong" do
        logitem = logformat.get_logitem "TDSCDMA_L1_Procedure_Information_TPC_SS_Information_DL_TPC1_1"
        logitem.should be_nil
      end
    end

    context "log group 100" do
      it "should be RecordId from the 100-0 from item_map" do
        logitem = logformat.item_map["RecordId"]
        logitem.name.should == "RecordId"
        logitem.type.should == "double"
        logitem.group.should == 100
        logitem.index.should == 0
      end
    end


  end
end