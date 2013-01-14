require "spec_helper"

module SpanReport::Condition
  describe Equal do
    let(:condition) { Equal.new("ie1", "5") }

    it "should be true whlie contain ie1=5" do
      validate_datas = {"ie1" => "5"}
      condition.validate?(validate_datas).should be_true
    end

    it "should be false while not contain ie1" do
      validate_datas = {"ie2" => "5"}
      condition.validate?(validate_datas).should be_false
    end

    it "should be false whild contain ie1, but not equal(ie=4)" do
      validate_datas = {"ie1" => "4"}
      condition.validate?(validate_datas).should be_false      
    end
  end
end