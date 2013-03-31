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

  describe OverRangeCount do  
    it "should be 1 when have no neicell " do
      time = "1000"
      ue = "1"
      data_map = {}
      data_map[SCELL_PCI] = "100"
      data_map[SCELL_FREQ] = "38350"
      data_map[SCELL_RSRP] = "-100"
      data_map[SCELL_SINR] = "0"

      # data_map[NCELL_PCI] = ""
      # data_map[NCELL_FREQ] = ""
      # data_map[NCELL_RSRP] = ""

      pointdata = PointData.new time, ue, data_map
      pointdata.expand_data
      OverRangeCount.static pointdata, @@config_map
      pointdata.over_range_count.should == 1
    end

    it "should be 2 when has one disturb nei cell" do
      time = "1000"
      ue = "1"
      data_map = {}
      data_map[SCELL_PCI] = "100"
      data_map[SCELL_FREQ] = "38350"
      data_map[SCELL_RSRP] = "-100"
      data_map[SCELL_SINR] = "0"

      data_map["#{NCELL_PCI}_0"] = "101"
      data_map["#{NCELL_FREQ}_0"] = "38350"
      data_map["#{NCELL_RSRP}_0"] = "-105"

      pointdata = PointData.new time, ue, data_map
      pointdata.expand_data
      OverRangeCount.static pointdata, @@config_map
      pointdata.over_range_count.should == 2
    end

    it "should be 1 when has one not disturb nei cell" do
      time = "1000"
      ue = "1"
      data_map = {}
      data_map[SCELL_PCI] = "100"
      data_map[SCELL_FREQ] = "38350"
      data_map[SCELL_RSRP] = "-100"
      data_map[SCELL_SINR] = "0"

      data_map["#{NCELL_PCI}_0"] = "101"
      data_map["#{NCELL_FREQ}_0"] = "38350"
      data_map["#{NCELL_RSRP}_0"] = "-110"

      pointdata = PointData.new time, ue, data_map
      pointdata.expand_data
      OverRangeCount.static pointdata, @@config_map
      pointdata.over_range_count.should == 1
    end

    it "should be correct when has 2 nei cells" do
      time = "1000"
      ue = "1"
      data_map = {}
      data_map[SCELL_PCI] = "100"
      data_map[SCELL_FREQ] = "38350"
      data_map[SCELL_RSRP] = "-100"
      data_map[SCELL_SINR] = "0"

      data_map["#{NCELL_PCI}_0"] = "101"
      data_map["#{NCELL_FREQ}_0"] = "38350"
      data_map["#{NCELL_RSRP}_0"] = "-110"

      data_map["#{NCELL_PCI}_1"] = "101"
      data_map["#{NCELL_FREQ}_1"] = "38350"
      data_map["#{NCELL_RSRP}_1"] = "-90"

      pointdata = PointData.new time, ue, data_map
      pointdata.expand_data
      OverRangeCount.static pointdata, @@config_map
      pointdata.over_range_count.should == 2
    end
  end


  # R N1  N2  N3  N4  N5  N6  N7  N8  N9  N10 N11 N12 N13 N14 N15 邻区干扰强度
  # -63 -72 -75 -76 -76 -81 -90 -90 -90 -91 -92 -94 -94 -95 -95 -97 1.3
  # -63 -63 -75 -76 -76 -82 -88 -90 -90 -91 -92 -92 -95 -95 -96 -97 10.0
  # -63 -65 -70 -72 -72 -82 -88 -89 -89 -91 -92 -93 -95 -96 -97 -97 10.8
  # -63 -64 -65 -66 -67 -68 -69 -70 -71 -91 -92 -93 -94 -97 -97 -99 32.5
  # -84 -79 -95 -95 -95 -95 -95 -95 -95 -95 -95 -95 -95 -97 -98 -98 31.6
  describe NCellDisturbCount do
    it "should cal correct the data 1" do
      time = "1000"
      ue = "1"
      data_map = {}
      data_map[SCELL_PCI] = "100"
      data_map[SCELL_FREQ] = "38350"
      data_map[SCELL_RSRP] = "-63"

      (0..7).each do |i|
        data_map["#{NCELL_PCI}_#{i}"] = "#{101+i}"
        data_map["#{NCELL_FREQ}_#{i}"] = "38350"
      end
      data_map["#{NCELL_RSRP}_0"] = "-72"
      data_map["#{NCELL_RSRP}_1"] = "-75"
      data_map["#{NCELL_RSRP}_2"] = "-76"
      data_map["#{NCELL_RSRP}_3"] = "-76"
      data_map["#{NCELL_RSRP}_4"] = "-81"
      data_map["#{NCELL_RSRP}_5"] = "-90"
      data_map["#{NCELL_RSRP}_6"] = "-90"
      data_map["#{NCELL_RSRP}_7"] = "-90"

      pointdata = PointData.new time, ue, data_map
      pointdata.expand_data
      NCellDisturbCount.static pointdata, @@config_map
      pointdata.disturb.round(1).should == 1.3
    end

    it "should cal correct the data 2" do
      time = "1000"
      ue = "1"
      data_map = {}
      data_map[SCELL_PCI] = "100"
      data_map[SCELL_FREQ] = "38350"
      data_map[SCELL_RSRP] = "-63"

      (0..7).each do |i|
        data_map["#{NCELL_PCI}_#{i}"] = "#{101+i}"
        data_map["#{NCELL_FREQ}_#{i}"] = "38350"
      end
      data_map["#{NCELL_RSRP}_0"] = "-63"
      data_map["#{NCELL_RSRP}_1"] = "-75"
      data_map["#{NCELL_RSRP}_2"] = "-76"
      data_map["#{NCELL_RSRP}_3"] = "-76"
      data_map["#{NCELL_RSRP}_4"] = "-81"
      data_map["#{NCELL_RSRP}_5"] = "-90"
      data_map["#{NCELL_RSRP}_6"] = "-90"
      data_map["#{NCELL_RSRP}_7"] = "-90"

      pointdata = PointData.new time, ue, data_map
      pointdata.expand_data
      NCellDisturbCount.static pointdata, @@config_map
      pointdata.disturb.round(1).should == 10
    end

    it "should cal correct the data 3" do
      time = "1000"
      ue = "1"
      data_map = {}
      data_map[SCELL_PCI] = "100"
      data_map[SCELL_FREQ] = "38350"
      data_map[SCELL_RSRP] = "-63"

      (0..7).each do |i|
        data_map["#{NCELL_PCI}_#{i}"] = "#{101+i}"
        data_map["#{NCELL_FREQ}_#{i}"] = "38350"
      end

      data_map["#{NCELL_RSRP}_0"] = "-65"
      data_map["#{NCELL_RSRP}_1"] = "-70"
      data_map["#{NCELL_RSRP}_2"] = "-72"
      data_map["#{NCELL_RSRP}_3"] = "-72"
      data_map["#{NCELL_RSRP}_4"] = "-82"
      data_map["#{NCELL_RSRP}_5"] = "-88"
      data_map["#{NCELL_RSRP}_6"] = "-89"
      data_map["#{NCELL_RSRP}_7"] = "-91"

      pointdata = PointData.new time, ue, data_map
      pointdata.expand_data
      NCellDisturbCount.static pointdata, @@config_map
      pointdata.disturb.round(1).should == 10.8
    end

    it "should cal correct the data 4" do
      time = "1000"
      ue = "1"
      data_map = {}
      data_map[SCELL_PCI] = "100"
      data_map[SCELL_FREQ] = "38350"
      data_map[SCELL_RSRP] = "-63"

      (0..7).each do |i|
        data_map["#{NCELL_PCI}_#{i}"] = "#{101+i}"
        data_map["#{NCELL_FREQ}_#{i}"] = "38350"
      end
      # -63 -64 -65 -66 -67 -68 -69 -70 -71 -91 -92 -93 -94 -97 -97 -99 32.5

      data_map["#{NCELL_RSRP}_0"] = "-64"
      data_map["#{NCELL_RSRP}_1"] = "-65"
      data_map["#{NCELL_RSRP}_2"] = "-66"
      data_map["#{NCELL_RSRP}_3"] = "-67"
      data_map["#{NCELL_RSRP}_4"] = "-68"
      data_map["#{NCELL_RSRP}_5"] = "-69"
      data_map["#{NCELL_RSRP}_6"] = "-70"
      data_map["#{NCELL_RSRP}_7"] = "-71"

      pointdata = PointData.new time, ue, data_map
      pointdata.expand_data
      NCellDisturbCount.static pointdata, @@config_map
      pointdata.disturb.round(1).should == 32.5
    end

    it "should cal correct the data 5" do
      time = "1000"
      ue = "1"
      data_map = {}
      data_map[SCELL_PCI] = "100"
      data_map[SCELL_FREQ] = "38350"
      data_map[SCELL_RSRP] = "-84"

      (0..7).each do |i|
        data_map["#{NCELL_PCI}_#{i}"] = "#{101+i}"
        data_map["#{NCELL_FREQ}_#{i}"] = "38350"
      end
      # -84 -79 -95 -95 -95 -95 -95 -95 -95 -95 -95 -95 -95 -97 -98 -98 31.6

      data_map["#{NCELL_RSRP}_0"] = "-79"
      data_map["#{NCELL_RSRP}_1"] = "-95"
      data_map["#{NCELL_RSRP}_2"] = "-95"
      data_map["#{NCELL_RSRP}_3"] = "-95"
      data_map["#{NCELL_RSRP}_4"] = "-95"
      data_map["#{NCELL_RSRP}_5"] = "-95"
      data_map["#{NCELL_RSRP}_6"] = "-95"
      data_map["#{NCELL_RSRP}_7"] = "-95"

      pointdata = PointData.new time, ue, data_map
      pointdata.expand_data
      NCellDisturbCount.static pointdata, @@config_map
      pointdata.disturb.round(1).should == 31.6
    end

  end

  describe EffectSinrCount do

    # S=10^(-67dbm/10)转换dbm为线性值；
    # I=10^(-62/10)+10^ (-70/10)+10^ (-74/10) +2*10^ (-86/10)+2*10^ (-87/10)+10^ (-90/10)；
    # N=10^ (-108/10)，N为网络底噪，通常可以忽略；
    # 等效SINR=-5.9db。

    it "should cal correct the effect sinr" do
      time = "1000"
      ue = "1"
      data_map = {}
      data_map[SCELL_PCI] = "100"
      data_map[SCELL_FREQ] = "38350"
      data_map[SCELL_RSRP] = "-67"

      (0..7).each do |i|
        data_map["#{NCELL_PCI}_#{i}"] = "#{101+i}"
        data_map["#{NCELL_FREQ}_#{i}"] = "38350"
      end

      data_map["#{NCELL_RSRP}_0"] = "-62"
      data_map["#{NCELL_RSRP}_1"] = "-70"
      data_map["#{NCELL_RSRP}_2"] = "-74"
      data_map["#{NCELL_RSRP}_3"] = "-86"
      data_map["#{NCELL_RSRP}_4"] = "-87"
      data_map["#{NCELL_RSRP}_5"] = "-90"
      data_map["#{NCELL_RSRP}_6"] = "-86"
      data_map["#{NCELL_RSRP}_7"] = "-87"

      pointdata = PointData.new time, ue, data_map
      pointdata.expand_data
      EffectSinrCount.static pointdata, @@config_map
      pointdata.effect_sinr.round(1).should == -5.9
    end
  end


end
