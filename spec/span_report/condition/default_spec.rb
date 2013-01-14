require "spec_helper"

module SpanReport::Condition
  describe Default do
    let(:condition) { Default.new }
    
    it "should parse return true" do
      condition.parse.should be_true
    end

    it "should validate true" do
      condition.validate?("").should be_true
    end
  end
end