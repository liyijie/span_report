# encoding: utf-8

require "spec_helper"
module SpanReport::Model
  describe KpiItem do
    context "simple ie eval" do
      it "should be eval the int value" do
        kpi_item = KpiItem.new(["kpi_test08", "test the kpi", "(<test_1>+<test_2>)/<test3>"])
        kpi_caches = {}
        kpi_value1 = SpanReport::Process::Value.create ""
        kpi_value1.add_value 1
        kpi_value2 = SpanReport::Process::Value.create ""
        kpi_value2.add_value 2
        kpi_value3 = SpanReport::Process::Value.create ""
        kpi_value3.add_value 3
        kpi_caches["test_1"] = kpi_value1
        kpi_caches["test_2"] = kpi_value2
        kpi_caches["test3"] = kpi_value3
        kpi_item.eval_value!(kpi_caches)
        kpi_caches["kpi_test08"].getvalue.should == 1
      end

      it "should be eval the value" do
        kpi_item = KpiItem.new(["kpi_test08", "test the kpi", "(<test_1>+<test_2>*1.0)/<test3>"])
        kpi_caches = {}
        kpi_value1 = SpanReport::Process::Value.create ""
        kpi_value1.add_value 3
        kpi_value2 = SpanReport::Process::Value.create ""
        kpi_value2.add_value "6"
        kpi_value3 = SpanReport::Process::Value.create ""
        kpi_value3.add_value 5
        kpi_caches["test_1"] = kpi_value1
        kpi_caches["test_2"] = kpi_value2
        kpi_caches["test3"] = kpi_value3
        kpi_item.eval_value!(kpi_caches)
        kpi_caches["kpi_test08"].getvalue.should == 1.8
      end

      it "should be eval the value" do
        kpi_item = KpiItem.new(["kpi_test08", "test the kpi", "(<test_1[0]>+<test_2[0]>*1.0)/<test3[0]>"])
        kpi_caches = {}
        kpi_value1 = SpanReport::Process::Value.create ""
        kpi_value1.add_value 3
        kpi_value2 = SpanReport::Process::Value.create ""
        kpi_value2.add_value "6"
        kpi_value3 = SpanReport::Process::Value.create ""
        kpi_value3.add_value 5
        kpi_caches["test_1[0]"] = kpi_value1
        kpi_caches["test_2[0]"] = kpi_value2
        kpi_caches["test3[0]"] = kpi_value3
        kpi_item.eval_value!(kpi_caches)
        kpi_caches["kpi_test08"].getvalue.should == 1.8
      end

      it "should be empty when the kpi value is invalid" do
        kpi_item = KpiItem.new(["kpi_test08", "test the kpi", "(<test_1[0]>+<test_2[0]>*1.0)/<test3[0]>"])
        kpi_caches = {}
        kpi_value1 = SpanReport::Process::Value.create ""
        kpi_value1.add_value 3
        kpi_value2 = SpanReport::Process::Value.create ""
        kpi_value2.add_value "5"
        kpi_value3 = SpanReport::Process::Value.create ""
        kpi_value3.add_value ""
        kpi_caches["test_1[0]"] = kpi_value1
        kpi_caches["test_2[0]"] = kpi_value2
        kpi_caches["test3[0]"] = kpi_value3
        kpi_item.eval_value!(kpi_caches)
        kpi_caches["kpi_test08"].getvalue.should == ""
      end
    end

    context "group kpi condition" do
      it "should be eval the value the group name is english" do
        kpi_item = KpiItem.new(["kpi_test08", "test the kpi", "(<cell#test_1[0]>+<cell#test_2[0]>*1.0)/<test3[0]>"])
        kpi_caches = {}
        kpi_value1 = SpanReport::Process::Value.create ""
        kpi_value1.add_value 3
        kpi_value2 = SpanReport::Process::Value.create ""
        kpi_value2.add_value "6"
        kpi_value3 = SpanReport::Process::Value.create ""
        kpi_value3.add_value 5
        kpi_caches["cell#test_1[0]"] = kpi_value1
        kpi_caches["cell#test_2[0]"] = kpi_value2
        kpi_caches["test3[0]"] = kpi_value3
        kpi_item.eval_value!(kpi_caches)
        kpi_caches["kpi_test08"].getvalue.should == 1.8
      end

      it "should be eval the value the group name is chinese" do
        kpi_item = KpiItem.new(["kpi_test08", "test the kpi", "(<小区#test_1[0]>+<cell#test_2[0]>*1.0)/<test3[0]>"])
        kpi_caches = {}
        kpi_value1 = SpanReport::Process::Value.create ""
        kpi_value1.add_value 3
        kpi_value2 = SpanReport::Process::Value.create ""
        kpi_value2.add_value "6"
        kpi_value3 = SpanReport::Process::Value.create ""
        kpi_value3.add_value 5
        kpi_caches["小区#test_1[0]"] = kpi_value1
        kpi_caches["cell#test_2[0]"] = kpi_value2
        kpi_caches["test3[0]"] = kpi_value3
        kpi_item.eval_value!(kpi_caches)
        kpi_caches["kpi_test08"].getvalue.should == 1.8
      end

    end


  end
end

