# encoding: utf-8

module SpanReport::Map

  # 外部调用，需要先config_export_file，否则不会输出
  class MapProcess < SpanReport::Process::Export
    
    def initialize
      super
      # reg_needed_ies
    end

    # def reg_needed_ies
    #   reg_ie_name "dbLon" ,"Longitude"
    #   reg_ie_name "dbLat" ,"Latitude"
    #   reg_ie_name "TDDLTE_Scell_Radio_Parameters_Scell_PCI" ,"i624"
    #   reg_ie_name "TDDLTE_Scell_Radio_Parameters_Frequency_DL" ,"i627"
    #   reg_ie_name "TDDLTE_L1_measurement_Serving_Cell_Measurement_RSRP" ,"i637"
    #   reg_ie_name "TDDLTE_L1_measurement_Serving_Cell_Measurement_SINR" ,"i642"
    #   reg_ie_name "TDDLTE_Throughput_APP_Throughput_DL" ,"i945"
    #   reg_ie_name "TDDLTE_Throughput_APP_Throughput_UL" ,"i946" 
    # end

    def process_csv_data data_map

      ue = data_map["ue"]
      time = data_map["time"]

      pointdata = SpanReport::Simulate::PointData.new(time, ue, data_map)
      pointdata.expand_data

      @export_datas << pointdata
      write_result
    end

    def flush
      @export_datas.each do |pointdata|
        mapdata = pointdata_to_mapdata pointdata
        @file.puts mapdata
      end
      @export_datas.clear
    end

    def head_string
      "Time,PCTime,UEid,Longitude,Latitude,i624,i627,i637,i642,i945,i946"
    end

    def pointdata_to_mapdata pointdata
      mapdata = ""
      mapdata << convert_time(pointdata.time.to_s) << ","
      mapdata << pointdata.time.to_s << ","
      mapdata << pointdata.ue.to_s << ","
      mapdata << pointdata.lon.to_s << ","
      mapdata << pointdata.lat.to_s << ","
      mapdata << pointdata.pci.to_s << ","
      mapdata << pointdata.freq.to_s << ","
      mapdata << pointdata.rsrp.to_s << ","
      mapdata << pointdata.sinr.to_s

      mapdata
    end
  end

end