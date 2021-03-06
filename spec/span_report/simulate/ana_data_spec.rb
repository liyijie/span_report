require "spec_helper"

module SpanReport::Simulate

  describe PointData do
    it "should be correct merge" do
      data1_map = {}
      data1_map[SCELL_PCI] = 5
      data1_map[SCELL_FREQ] = 6
      data1 = PointData.new(1,1,data1_map)

      data2_map = {}
      data2_map[SCELL_PCI] = 8
      data2_map[SCELL_FREQ] = 9
      data2_map["#{NCELL_PCI}_0"] = 9
      data2_map["#{NCELL_FREQ}_0"] = 10
      data2_map["#{NCELL_PCI}_1"] = 11
      data2_map["#{NCELL_FREQ}_1"] = 12
      data2 = PointData.new(2,2,data2_map)

      data1.merge! data2
      data1.expand_data
      data1.lat.should be_nil
      data1.pci.should == 8
      data1.freq.should == 9
      data1.nei_cells.size.should == 2
      data1.nei_cells[0].pci.should == 9
      data1.nei_cells[1].pci.should == 11
    end

    it "should be correct fill" do
      data_map = {}
      data_map[LAT] = 5
      data_map[LON] = 6
      data_map[SCELL_SINR] = 7
      point_data = PointData.new(1,1,data_map)
      point_data.serve_cell.should be_nil

      holdlast_data = HoldlastData.new
      holdlast_data.lat = 6
      holdlast_data.pci = 9
      holdlast_data.sinr = 10
      point_data.fill holdlast_data
      point_data.lat.should == 6
      point_data.pci.should == 9
      point_data.sinr.should == 10
      point_data.freq.should be_nil
    end

    it "should be sort cells by rsrp" do
      point_data = PointData.new(1,1)
      point_data.sort_cells
      point_data.serve_cell.should be_nil
      point_data.nei_cells.should be_nil

      # [3,2,5,6,1,7] => [7,6,5,3,2,1]
      data_map = {}
      data_map[SCELL_PCI] = 3
      data_map[SCELL_RSRP] = 3
      data_map["#{NCELL_PCI}_0"] = 2
      data_map["#{NCELL_RSRP}_0"] = 2
      data_map["#{NCELL_PCI}_1"] = 5
      data_map["#{NCELL_RSRP}_1"] = 5
      data_map["#{NCELL_PCI}_2"] = 6
      data_map["#{NCELL_RSRP}_2"] = 6
      data_map["#{NCELL_PCI}_3"] = 1
      data_map["#{NCELL_RSRP}_3"] = 1
      data_map["#{NCELL_PCI}_4"] = 7
      data_map["#{NCELL_RSRP}_4"] = 7
      point_data = PointData.new(1,1,data_map)
      point_data.expand_data
      point_data.nei_cells.size.should == 5
      point_data.sort_cells

      point_data.pci.should == 7
      point_data.rsrp.should == 7
      point_data.nei_cells.size.should == 5
      point_data.nei_cells[0].rsrp.should == 6
      point_data.nei_cells[1].rsrp.should == 5
      point_data.nei_cells[2].rsrp.should == 3
      point_data.nei_cells[3].rsrp.should == 2
      point_data.nei_cells[4].rsrp.should == 1
    end

    it "should be valid when the nei_cells is not empty" do
      point_data = PointData.new(1,1)
      point_data.valid?.should be_false

      data_map = {}
      data_map["#{NCELL_PCI}_0"] = 2
      data_map["#{NCELL_RSRP}_0"] = 2
      point_data = PointData.new(1,1,data_map)
      point_data.expand_data
      point_data.sort_cells
      point_data.valid?.should be_false
      point_data.nei_cells.should be_empty

      data_map = {}
      data_map["#{NCELL_PCI}_0"] = 2
      data_map["#{NCELL_RSRP}_0"] = 2
      data_map["#{NCELL_PCI}_1"] = 1
      data_map["#{NCELL_RSRP}_2"] = 1
      point_data = PointData.new(1,1,data_map)
      point_data.expand_data
      point_data.sort_cells
      point_data.valid?.should be_true
    end
  end

  describe CellData do
    
  end
end