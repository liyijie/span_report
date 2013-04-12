# encoding: utf-8

module SpanReport::Map

  # 外部调用，需要先config_export_file，否则不会输出
  class MapProcess < SpanReport::Process::Export
    
    def initialize result_path
      super()
      @result_path = result_path
    end


    def open_file result_file
      puts "export file is:#{result_file}"
      @file = File.new(result_file, "w")
      @file.puts head_string
    end

    def process_csv_data data_map

      ue = data_map["ue"]
      time = data_map["time"]

      pointdata = SpanReport::Simulate::PointData.new(time, ue, data_map)
      pointdata.expand_data

      @export_datas << pointdata
      write_result
    end

    def process_pointdata point_data
      @export_datas << point_data
      write_result
    end

    def flush
      open_file(File.join @result_path, "全部轨迹.csv") if @file.nil?
      @export_datas.each do |pointdata|
        mapdata = pointdata_to_mapdata pointdata
        @file.puts mapdata
      end
      @export_datas.clear
    end

    def close_file
      flush
      @file.close if @file
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