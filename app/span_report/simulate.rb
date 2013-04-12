# encoding: utf-8

module SpanReport
  module Simulate
    autoload :PointData, "span_report/simulate/ana_data"
    autoload :CellInfos, "span_report/simulate/cell_infos"
    autoload :SimulateProcess, "span_report/simulate/simulate_process"
    autoload :ConvertFileProcess, "span_report/simulate/convert_file_process"
    autoload :HoldlastData, "span_report/simulate/convert_file_process"
    autoload :PointKpiProcess, "span_report/simulate/point_kpi_process.rb"
    autoload :OverRangeCount, "span_report/simulate/point_kpi_process.rb"
    autoload :NCellDisturbCount, "span_report/simulate/point_kpi_process.rb"

    #cell kpi process
    autoload :CellKpiProcess, "span_report/simulate/cell_kpi_process.rb"
    autoload :WeakCoverRatioKpi, "span_report/simulate/cell_kpi_process.rb"
    autoload :OverLapCoverRatioKpi, "span_report/simulate/cell_kpi_process.rb"
    autoload :NCellDisturbRatioKpi, "span_report/simulate/cell_kpi_process.rb"
    autoload :DisturbRatioKpi, "span_report/simulate/cell_kpi_process.rb"
    autoload :HighDisturbRatioKpi, "span_report/simulate/cell_kpi_process.rb"
    autoload :EffectSinrKpi, "span_report/simulate/cell_kpi_process.rb"


    ANA_NCELL_NUM = 8

    LON = "lontitute"
    LAT = "latitude"
    SCELL_PCI = "scell_pci"
    SCELL_FREQ = "scell_freq"
    SCELL_RSRP = "scell_rsrp"
    SCELL_SINR = "scell_sinr"
    SCELL_NAME = "scell_name"
    SCELL_DISTANCE = "scell_distance"
    NCELL_PCI = "ncell_pci"
    NCELL_FREQ = "ncell_freq"
    NCELL_RSRP = "ncell_rsrp"
    NCELL_NAME = "ncell_name"
    NCELL_DISTANCE = "ncell_distance"

    # 邻区干扰阈值（dB）  邻小区电平值与主服务小区电平值之差大于该阈值，
    # 则认为邻小区对主服务小区会产生干扰。默认-10dB，可修改  -10
    DISTURB_THRESHOLD = "disturb"
    # 邻区干扰强度阈值  作为邻区干扰强度是否达标的判断，默认30，可修改  30    
    DISTURB_STRENGTH_THRESHOLD = "disturb_strength"
    # TDS模拟TDL补偿值 将TDS的RSCP转换为TDL的RSRP的差值 18
    TDS_TDL_DELTA = "tds_tdl_delta"
    # 弱覆盖阈值（dBm）  采样点中主服务小区TDL-RSRP、TDL-等效RSRP或TDS-RSCP低于该阈值，
    # 则认为该采样点为弱覆盖采样点，用于计算弱覆盖系数。默认-100，可修改  -95/-100（TDS/TDL）
    TDS_WEAK_COVER_THRESHOLD = "tds_weak_cover"
    TDL_WEAK_COVER_THRESHOLD = "tdl_weak_cover"
    # 重叠覆盖小区数阈值 作为道路重叠覆盖小区数是否达标的判断，默认3，可修改  3
    OVERLAP_COVER_THRESHOLD = "overlap_cover"
    # 邻区有效性阈值（dBm）  采样点邻区电平强度高于该阈值，则认为是有效测量，默认-105，可修改。 -105
    NCELL_VALID_THRESHOLD = "ncell_valid"
    # 过覆盖阈值（%）  如果干扰采样点数/有效采样点数大于过覆盖阈值，则计为过覆盖，默认50%，可修改。  50%
    OVER_COVER_RATIO_THRESHOLD = "over_cover_ratio"
    # 高干扰阈值（dB） 定义SINR、等效SINR、C/I门限，默认6dB，可修改 6
    HIGH_DISTURB_THRESHOLD = "high_disturb"
    # 需要过滤的距离
    DISTANCE_FILTER = "distance_filter"
  end
end