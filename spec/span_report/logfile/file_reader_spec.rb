require "spec_helper"

module SpanReport::Logfile

  describe FileReader do
    
    let(:filereader) { FileReader.new "log/1.lgl" }

    it "should be correct unzip" do
      filereader.unzip "log/新建文件夹/1.lgl", "config"
      filereader.clear_files
    end

    context "test the file group funcition" do
      it "should be empty when the file group is not given" do
        filereader.get_file_group("log/1.lgl").should == ""
        filereader.get_file_group("1.lgl").should == ""
        filereader.get_file_group("log/log.1/1.lgl").should == ""
      end

      it "should get file group form the last 2 position" do
        filereader.get_file_group("log/1.test-1.lgl").should == "test-1"
        filereader.get_file_group("2.1.test-1.lgl").should == "test-1"
        filereader.get_file_group("log/log.1/2.1.test-1.lgl").should == "test-1"        
      end
    end

  end
  
end