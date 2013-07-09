# encoding : utf-8

module SpanReport::Context

  ANA_NCELL_NUM = 8

  LON = "lontitute"
  LAT = "latitude"
  DL_TH = "dl_throughput"
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

  class OverlapContext < BaseContext

    def load_relate
      doc = Nokogiri::XML(open(CONFIG_FILE))
      doc.search(@function).each do |relate|
        @disturb_threshold = get_content relate, "disturb_threshold"
      end
    end

    def process
      SpanReport::Model::Logformat.instance.load_xml "config/LogFormat_100.xml"
      output_file = File.join @output_log, "overlap.csv"
      overlap_process = OverlapProcess.new @disturb_threshold, output_file

      logfiles = SpanReport.list_files(@input_log, ["lgl"])
      begin
        filereader = SpanReport::Logfile::FileReader.new logfiles
        filereader.parse(overlap_process)
      rescue Exception => e
        puts e
        puts e.backtrace
      ensure
        filereader.clear_files
        overlap_process.close_file
      end
    end

  end


  class OverlapProcess < SpanReport::Process::Base
    
    def initialize disturb_threshold, result_file
      super()
      @disturb_threshold = disturb_threshold
      @last_point_data = nil
      @holdlast_data = HoldlastData.new
      @csv_writer = OverlapCsv.new result_file 
      reg_needed_ies
    end

    def process_data logdata, file_group=""
      contents = logdata.split(/,|:/)
      group_id = contents[1].to_i
      needed_ies = get_needed_ies group_id
      time = contents[2]
      ue = contents[0]
      data_map = {}

      needed_ies.each do |logitem|
        ie_name = logitem.name
        ie_index = logitem.index + 3
        if contents[ie_index] && !contents[ie_index].empty? && contents[ie_index] != "-999"
          data_map[@alis_map[ie_name]] = contents[ie_index]
        end
      end

      add_logdata_map time, ue, data_map
    end

    def close_file
      @csv_writer.close_file if @csv_writer
    end

    private

    def add_logdata_map time, ue, data_map
      point_data = SpanReport::Simulate::PointData.new time, ue, data_map
      @last_point_data = point_data unless @last_point_data
      if @last_point_data.merge? point_data
        @last_point_data.merge! point_data
      else
        # 这里说明来了一条新的时间数据
        @last_point_data.expand_data
        @holdlast_data.fill @last_point_data
        #保存最新的值到hold last中
        # 再从holdlast data中填充GPS和主服务小区的数据
        # 
        if @last_point_data.valid?
          @last_point_data.fill @holdlast_data
          SpanReport::Simulate::OverRangeCount.static @last_point_data, "disturb" => @disturb_threshold
          @csv_writer << @last_point_data
        end
        # 
        @last_point_data = point_data
      end
    end

    def reg_needed_ies
      reg_iemap = get_reg_iemap
      reg_iemap.each do |iename, aliasname|
        reg_iename iename, aliasname
      end
    end

    def get_reg_iemap
      reg_iemap = {}
      reg_iemap["dbLon"] = LON
      reg_iemap["dbLat"] = LAT
      reg_iemap["TDDLTE_Throughput_APP_Throughput_DL"] = DL_TH

      reg_iemap["TDDLTE_Scell_Radio_Parameters_Scell_PCI"] = SCELL_PCI
      reg_iemap["TDDLTE_Scell_Radio_Parameters_Frequency_DL"] = SCELL_FREQ
      reg_iemap["TDDLTE_L1_measurement_Serving_Cell_Measurement_RSRP"] = SCELL_RSRP
      reg_iemap["TDDLTE_L1_measurement_Serving_Cell_Measurement_SINR"] = SCELL_SINR

      (0..ANA_NCELL_NUM-1).each do |i|
        reg_iemap["TDDLTE_L1_measurement_Neighbour_Cell_Measurement_PCI_#{i}"] = "#{NCELL_PCI}_#{i}"
        reg_iemap["TDDLTE_L1_measurement_Neighbour_Cell_Measurement_EARFCN_#{i}"] = "#{NCELL_FREQ}_#{i}"
        reg_iemap["TDDLTE_L1_measurement_Neighbour_Cell_Measurement_RSRP_#{i}"] = "#{NCELL_RSRP}_#{i}"
      end
      reg_iemap
    end
  end

  class OverlapCsv < SpanReport::Logfile::CsvWriter
    
    def head_string
      "LTE,PCTime,UEid,Longitude,Latitude,i624,i627,i637,i642,over_range_count"
    end

    def flush
      @export_datas.each do |pointdata|
        mapdata = ""
        mapdata << "LTE" << ","
        mapdata << pointdata.time.to_s << ","
        mapdata << pointdata.ue.to_s << ","
        mapdata << pointdata.lon.to_s << ","
        mapdata << pointdata.lat.to_s << ","
        mapdata << pointdata.pci.to_s << ","
        mapdata << pointdata.freq.to_s << ","
        mapdata << pointdata.rsrp.to_s << ","
        mapdata << pointdata.sinr.to_s << ","
        mapdata << pointdata.over_range_count.to_s
        @file.puts mapdata
      end
      @export_datas.clear
    end


  end

  class HoldlastData
    attr_accessor :lat, :lon, :pci, :freq, :rsrp, :sinr

    def fill point_data
      @lat = point_data.lat if point_data.lat
      @lon = point_data.lon if point_data.lon
      @pci = point_data.serve_cell.pci if point_data.serve_cell && point_data.serve_cell.pci
      @freq = point_data.serve_cell.freq if point_data.serve_cell && point_data.serve_cell.freq
      @rsrp = point_data.serve_cell.rsrp if point_data.serve_cell && point_data.serve_cell.rsrp
      @sinr = point_data.serve_cell.sinr if point_data.serve_cell && point_data.serve_cell.sinr
    end 
  end
end
