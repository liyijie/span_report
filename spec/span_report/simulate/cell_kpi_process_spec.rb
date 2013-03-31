require "spec_helper"

module SpanReport::Simulate

  @@config_map = {}
  @@config_map[DISTURB_THRESHOLD] = -10
  @@config_map[DISTURB_STRENGTH_THRESHOLD] = 30
  @@config_map[TDS_TDL_DELTA] = 18
  @@config_map[TDS_WEAK_COVER_THRESHOLD] = -95
  @@config_map[TDL_WEAK_COVER_THRESHOLD] = -100
  @@config_map[OVERLAP_COVER_THRESHOLD] = 3
  @@config_map[NCELL_VALID_THRESHOLD] = -105
  @@config_map[OVER_COVER_RATIO_THRESHOLD] = 0.5
  @@config_map[HIGH_DISTURB_THRESHOLD] = 6

  describe CellKpiProcess do

    it "should correct cal cell kpi" do
      cellkpi_process = CellKpiProcess.new @@config_map
      time = "1000"
      ue = "1"

      #N(a)=-50, E(a)=-116
      data_map = {}
      data_map[SCELL_PCI] = "102"
      data_map[SCELL_FREQ] = "38350"
      data_map[SCELL_RSRP] = "-66"
      data_map[SCELL_SINR] = "0"
      data_map[SCELL_NAME] = "小区c"
      data_map["#{NCELL_PCI}_0"] = "100"
      data_map["#{NCELL_FREQ}_0"] = "38350"
      data_map["#{NCELL_RSRP}_0"] = "-116"
      data_map["#{NCELL_NAME}_0"] = "小区a"
      pointdata = PointData.new time, ue, data_map
      pointdata.expand_data
      PointKpiProcess.process_pointdata pointdata, @@config_map
      cellkpi_process.process_pointdata pointdata

      #N(a)=-40, E(a)=-116, CellC
      data_map = {}
      data_map[SCELL_PCI] = "102"
      data_map[SCELL_FREQ] = "38350"
      data_map[SCELL_RSRP] = "-76"
      data_map[SCELL_SINR] = "0"
      data_map[SCELL_NAME] = "小区c"
      data_map["#{NCELL_PCI}_0"] = "100"
      data_map["#{NCELL_FREQ}_0"] = "38350"
      data_map["#{NCELL_RSRP}_0"] = "-116"
      data_map["#{NCELL_NAME}_0"] = "小区a"
      pointdata = PointData.new time, ue, data_map
      pointdata.expand_data
      PointKpiProcess.process_pointdata pointdata, @@config_map
      cellkpi_process.process_pointdata pointdata

      #N(a)=-8, E(a)=-103, CellC
      data_map = {}
      data_map[SCELL_PCI] = "102"
      data_map[SCELL_FREQ] = "38350"
      data_map[SCELL_RSRP] = "-95"
      data_map[SCELL_SINR] = "0"
      data_map[SCELL_NAME] = "小区c"
      data_map["#{NCELL_PCI}_0"] = "100"
      data_map["#{NCELL_FREQ}_0"] = "38350"
      data_map["#{NCELL_RSRP}_0"] = "-103"
      data_map["#{NCELL_NAME}_0"] = "小区a"
      pointdata = PointData.new time, ue, data_map
      pointdata.expand_data
      PointKpiProcess.process_pointdata pointdata, @@config_map
      cellkpi_process.process_pointdata pointdata

      #N(a)=-15, E(a)=-95, CellB
      data_map = {}
      data_map[SCELL_PCI] = "101"
      data_map[SCELL_FREQ] = "38350"
      data_map[SCELL_RSRP] = "-80"
      data_map[SCELL_SINR] = "0"
      data_map[SCELL_NAME] = "小区b"
      data_map["#{NCELL_PCI}_0"] = "100"
      data_map["#{NCELL_FREQ}_0"] = "38350"
      data_map["#{NCELL_RSRP}_0"] = "-95"
      data_map["#{NCELL_NAME}_0"] = "小区a"
      pointdata = PointData.new time, ue, data_map
      pointdata.expand_data
      PointKpiProcess.process_pointdata pointdata, @@config_map
      cellkpi_process.process_pointdata pointdata

      #N(a)=-7, E(a)=-87, CellB
      data_map = {}
      data_map[SCELL_PCI] = "101"
      data_map[SCELL_FREQ] = "38350"
      data_map[SCELL_RSRP] = "-80"
      data_map[SCELL_SINR] = "0"
      data_map[SCELL_NAME] = "小区b"
      data_map["#{NCELL_PCI}_0"] = "100"
      data_map["#{NCELL_FREQ}_0"] = "38350"
      data_map["#{NCELL_RSRP}_0"] = "-87"
      data_map["#{NCELL_NAME}_0"] = "小区a"
      pointdata = PointData.new time, ue, data_map
      pointdata.expand_data
      PointKpiProcess.process_pointdata pointdata, @@config_map
      cellkpi_process.process_pointdata pointdata

      #N(a)=-9, E(a)=-75, CellB
      data_map = {}
      data_map[SCELL_PCI] = "101"
      data_map[SCELL_FREQ] = "38350"
      data_map[SCELL_RSRP] = "-66"
      data_map[SCELL_SINR] = "0"
      data_map[SCELL_NAME] = "小区b"
      data_map["#{NCELL_PCI}_0"] = "100"
      data_map["#{NCELL_FREQ}_0"] = "38350"
      data_map["#{NCELL_RSRP}_0"] = "-75"
      data_map["#{NCELL_NAME}_0"] = "小区a"
      pointdata = PointData.new time, ue, data_map
      pointdata.expand_data
      PointKpiProcess.process_pointdata pointdata, @@config_map
      cellkpi_process.process_pointdata pointdata

      #N(a)=-7, E(a)=-78, CellD
      data_map = {}
      data_map[SCELL_PCI] = "103"
      data_map[SCELL_FREQ] = "38350"
      data_map[SCELL_RSRP] = "-71"
      data_map[SCELL_SINR] = "0"
      data_map[SCELL_NAME] = "小区d"
      data_map["#{NCELL_PCI}_0"] = "100"
      data_map["#{NCELL_FREQ}_0"] = "38350"
      data_map["#{NCELL_RSRP}_0"] = "-78"
      data_map["#{NCELL_NAME}_0"] = "小区a"
      pointdata = PointData.new time, ue, data_map
      pointdata.expand_data
      PointKpiProcess.process_pointdata pointdata, @@config_map
      cellkpi_process.process_pointdata pointdata

      #N(a)=-7, E(a)=-86, CellD
      data_map = {}
      data_map[SCELL_PCI] = "103"
      data_map[SCELL_FREQ] = "38350"
      data_map[SCELL_RSRP] = "-79"
      data_map[SCELL_SINR] = "0"
      data_map[SCELL_NAME] = "小区d"
      data_map["#{NCELL_PCI}_0"] = "100"
      data_map["#{NCELL_FREQ}_0"] = "38350"
      data_map["#{NCELL_RSRP}_0"] = "-86"
      data_map["#{NCELL_NAME}_0"] = "小区a"
      pointdata = PointData.new time, ue, data_map
      pointdata.expand_data
      PointKpiProcess.process_pointdata pointdata, @@config_map
      cellkpi_process.process_pointdata pointdata

      #N(a)=-8, E(a)=-65, CellD
      data_map = {}
      data_map[SCELL_PCI] = "103"
      data_map[SCELL_FREQ] = "38350"
      data_map[SCELL_RSRP] = "-57"
      data_map[SCELL_SINR] = "0"
      data_map[SCELL_NAME] = "小区d"
      data_map["#{NCELL_PCI}_0"] = "100"
      data_map["#{NCELL_FREQ}_0"] = "38350"
      data_map["#{NCELL_RSRP}_0"] = "-65"
      data_map["#{NCELL_NAME}_0"] = "小区a"
      pointdata = PointData.new time, ue, data_map
      pointdata.expand_data
      PointKpiProcess.process_pointdata pointdata, @@config_map
      cellkpi_process.process_pointdata pointdata

      #N(a)=-11, E(a)=-78, CellD
      data_map = {}
      data_map[SCELL_PCI] = "103"
      data_map[SCELL_FREQ] = "38350"
      data_map[SCELL_RSRP] = "-67"
      data_map[SCELL_SINR] = "0"
      data_map[SCELL_NAME] = "小区d"
      data_map["#{NCELL_PCI}_0"] = "100"
      data_map["#{NCELL_FREQ}_0"] = "38350"
      data_map["#{NCELL_RSRP}_0"] = "-78"
      data_map["#{NCELL_NAME}_0"] = "小区a"
      pointdata = PointData.new time, ue, data_map
      pointdata.expand_data
      PointKpiProcess.process_pointdata pointdata, @@config_map
      cellkpi_process.process_pointdata pointdata

      #N(a)=-12, E(a)=-71, CellD
      data_map = {}
      data_map[SCELL_PCI] = "103"
      data_map[SCELL_FREQ] = "38350"
      data_map[SCELL_RSRP] = "-59"
      data_map[SCELL_SINR] = "0"
      data_map[SCELL_NAME] = "小区d"
      data_map["#{NCELL_PCI}_0"] = "100"
      data_map["#{NCELL_FREQ}_0"] = "38350"
      data_map["#{NCELL_RSRP}_0"] = "-71"
      data_map["#{NCELL_NAME}_0"] = "小区a"
      pointdata = PointData.new time, ue, data_map
      pointdata.expand_data
      PointKpiProcess.process_pointdata pointdata, @@config_map
      cellkpi_process.process_pointdata pointdata

      #N(a)=-9, E(a)=-87, CellD
      data_map = {}
      data_map[SCELL_PCI] = "103"
      data_map[SCELL_FREQ] = "38350"
      data_map[SCELL_RSRP] = "-78"
      data_map[SCELL_SINR] = "0"
      data_map[SCELL_NAME] = "小区d"
      data_map["#{NCELL_PCI}_0"] = "100"
      data_map["#{NCELL_FREQ}_0"] = "38350"
      data_map["#{NCELL_RSRP}_0"] = "-87"
      data_map["#{NCELL_NAME}_0"] = "小区a"
      pointdata = PointData.new time, ue, data_map
      pointdata.expand_data
      PointKpiProcess.process_pointdata pointdata, @@config_map
      cellkpi_process.process_pointdata pointdata

      #N(a)=-11, E(a)=-81, CellD
      data_map = {}
      data_map[SCELL_PCI] = "103"
      data_map[SCELL_FREQ] = "38350"
      data_map[SCELL_RSRP] = "-70"
      data_map[SCELL_SINR] = "0"
      data_map[SCELL_NAME] = "小区d"
      data_map["#{NCELL_PCI}_0"] = "100"
      data_map["#{NCELL_FREQ}_0"] = "38350"
      data_map["#{NCELL_RSRP}_0"] = "-81"
      data_map["#{NCELL_NAME}_0"] = "小区a"
      pointdata = PointData.new time, ue, data_map
      pointdata.expand_data
      PointKpiProcess.process_pointdata pointdata, @@config_map
      cellkpi_process.process_pointdata pointdata


      cellkpi_process.cal_kpi_value
      cell_kpivalue_map = cellkpi_process.cell_kpivalue_map
      disturb_ratio_kpi = cell_kpivalue_map["小区a"].disturb_ratio_kpi
      disturb_ratio_kpi.to_f.round(4).should == 0.6364  
    end
    
  end
end
