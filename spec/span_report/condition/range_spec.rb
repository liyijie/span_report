require "spec_helper"

module SpanReport::Condition
  describe Range do    
    context "range is [-10.5, 3]" do
      let(:range) { Range.new("ie1", "[-10.5, 3]") }

      before(:each) do
        range.parse
      end

      it "should be true in the range" do
        range.validate?({"ie1" => "-10.50"}).should be_true
        range.validate?({"ie1" => "-10"}).should be_true
        range.validate?({"ie1" => "0"}).should be_true
        range.validate?({"ie1" => "2"}).should be_true
        range.validate?({"ie1" => "3"}).should be_true
      end

      it "should be false out of the range" do
        range.validate?({"ie1" => "-11.5"}).should be_false
        range.validate?({"ie1" => "3.5"}).should be_false
      end

      it "should be false where the relate ie is not contain" do
        range.validate?({"ie2" => "3.5"}).should be_false        
        range.validate?({"ie2" => "2"}).should be_false        
      end
    end

    context "range is (-10.5, 3)" do
      let(:range) { Range.new("ie1", "(-10.5, 3)") }

      before(:each) do
        range.parse
      end

      it "should not contain the border" do
        range.validate?({"ie1" => "-10.5"}).should be_false
        range.validate?({"ie1" => "3"}).should be_false
        range.validate?({"ie1" => "2"}).should be_true
      end
    end

    context "range is [-10.5, 3)" do
      let(:range) { Range.new("ie1", "[-10.5, 3)") }

      before(:each) do
        range.parse
      end

      it "should not contain the border" do
        range.validate?({"ie1" => "-10.5"}).should be_true
        range.validate?({"ie1" => "3"}).should be_false
        range.validate?({"ie1" => "2"}).should be_true
      end
    end

    context "range is (-10.5, 3]" do
      let(:range) { Range.new("ie1", "(-10.5, 3]") }

      before(:each) do
        range.parse
      end

      it "should not contain the border" do
        range.validate?({"ie1" => "-10.5"}).should be_false
        range.validate?({"ie1" => "3"}).should be_true
        range.validate?({"ie1" => "2"}).should be_true
      end
    end
  end
end
