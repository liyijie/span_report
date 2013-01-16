require "spec_helper"

module SpanReport
  
  describe Cache do
    
    let(:cache) { Cache.new }
    context "have no condition" do
      it "should get by the kpiname" do
        # kpiname = ""
        # cache.get_kpi_value(kpiname).should be_empty
        # cache.add_logdata(counter_data)
        # cache.get_kpi_value(kpiname).should == "3"
        # cache.add_logdata(relate_data)
        # cache.get_kpi_value(kpiname).should be_empty
        # cache.add_logdata(counter_data)
        # cache.get_kpi_value.should == "5"
      end
      
      it "should description" do
        
      end
    end
  end
end