require "spec_helper"

module SpanReport::Logfile

  describe FileReader do
    
    let(:filereader) { FileReader.new "log/1.lgl" }

    it "should be correct unzip" do
      filereader.unzip "log/1.lgl", "config"
    end

  end
  
end