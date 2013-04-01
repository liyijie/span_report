require "spec_helper"

module SpanReport::Simulate

  describe HoldlastData do
    it "should be empty when the data is not filled" do
      holdlast_data = HoldlastData.new
      holdlast_data.lat.should be_nil
      holdlast_data.lon.should be_nil
      holdlast_data.pci.should be_nil
      holdlast_data.rsrp.should be_nil
      holdlast_data.sinr.should be_nil
    end

    it "should be the right value when the data is filled" do
      holdlast_data = HoldlastData.new
      point_data = PointData.new(1,1)

      holdlast_data.fill point_data
      holdlast_data.lat.should be_nil
      holdlast_data.lon.should be_nil
      holdlast_data.pci.should be_nil
      holdlast_data.rsrp.should be_nil
      holdlast_data.sinr.should be_nil

      point_data.lat = 223.2
      holdlast_data.fill point_data
      holdlast_data.lat.should == 223.2
      point_data.lat = -229
      holdlast_data.fill point_data
      holdlast_data.lat.should == -229

      data_map = {SCELL_PCI => 5}
      point_data = PointData.new(1,1,data_map)
      holdlast_data.fill point_data
      holdlast_data.lat.should == -229
      holdlast_data.pci.should be_nil

      point_data.expand_data
      holdlast_data.fill point_data
      holdlast_data.pci.should == 5
      holdlast_data.rsrp.should be_nil
    end
  end
  
end