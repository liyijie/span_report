require "spec_helper"

module SpanReport::Model
  describe CounterItem do
    it "should be clone with the deep copy" do
      item = CounterItem.new
      item.self_condition = []
      item.relate_conditions = []

      item_clone = item.clone
      item_clone.self_condition << "5"

      item.self_condition.should be_empty
    end

    it "should be dup with the deep copy" do
      item = CounterItem.new
      item.self_condition = []
      item.relate_conditions = []

      item_dup = item.clone
      item_dup.self_condition << "5"

      item.self_condition.should be_empty
    end
  end
end