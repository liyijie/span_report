require "spec_helper"

module SpanReport::Context
  describe BaseContext do
    let(:context) { BaseContext.new }
    
    it "should load common info" do
      context.load_common
      context.input_log.should == "./log"
      context.output_log.should == "./log"
      context.function.should == "report"        
    end
  end
end