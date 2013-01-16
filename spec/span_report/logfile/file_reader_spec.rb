require "spec_helper"

module SpanReport::Logfile

  describe FileReader do
    
    let(:filereader) { FileReader.new "config/1.lgl" }

    it "should be correct unzip" do
      filereader.unzip "config/1.lgl", "config/temp"
    end

  end
  
end