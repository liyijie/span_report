#encoding: utf-8

module SpanReport::Simulate

  class ConvertFileProcess < SpanReport::Process::Base

    def initialize csv_file, cell_infos
      super()
      @cell_infos = cell_infos
      @last_point_data = nil
      @holdlast_data = HoldlastData.new
      reg_needed_ies
      csv_writer = SpanReport::Logfile::CsvWriter.new csv_file
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

    private

    def add_logdata_map time, ue, data_map
      point_data = PointData.new time, ue, data_map
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
          @last_point_data.fill_extra @cell_infos
          csv_writer << @last_point_data
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