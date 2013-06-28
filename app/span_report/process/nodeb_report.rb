# encoding: utf-8

module SpanReport::Process
  
  class NodebReport < Report

    PCI_IENAME = "TDDLTE_Scell_Radio_Parameters_Scell_PCI"
    FREQ_IENAME = "TDDLTE_Scell_Radio_Parameters_Frequency_DL"
    LAT_NAME = "dbLat"
    LON_NAME = "dbLon"

    attr_reader :relate_nodebs

    ########################################
    #处理日志中的一条数据
    #这里已经通过校验，已经是包含需要处理的数据
    #1. 把日志数据中相关的IE都能加入到IE缓存中
    #2. 如果是counter相关的数据，则计算相关的counter值
    #
    #########################################
    def initialize
      super
      @pci_freq_map = {}
      @last_pci_freq_key = ""
      @last_nodeb = ""
      @last_cell = ""
      @relate_nodebs = Set.new
    end

    def add_counter_cache counter_name, counter_ievalue, count_mode, pctime=0, is_valid=true
      super counter_name, counter_ievalue, count_mode, pctime, is_valid
      #对符合用户给定基站小区信息的，需要进行统计
      cell_pci = @ie_caches[PCI_IENAME]
      cell_freq = @ie_caches[FREQ_IENAME]
      cell_pci ||= ""
      cell_freq ||= ""
      pci_freq_key = "#{cell_pci}_#{cell_freq}"

      nodeb_name = ""
      cell_name = ""
      if @last_pci_freq_key == pci_freq_key
        nodeb_name = @last_nodeb
        cell_name = @last_cell
      else
        if @pci_freq_map.has_key? pci_freq_key
          cell_infos = @pci_freq_map[pci_freq_key]

          point = Point.new @ie_caches[LAT_NAME], @ie_caches[LON_NAME]

          min_dis = nil
          near_cell_info = nil
          SpanReport.logger.debug "last_pci_freq_key is:#{@last_pci_freq_key}"
          SpanReport.logger.debug "pci_freq_key is:#{pci_freq_key}"
          SpanReport.logger.debug "gps info is:#{@ie_caches[LAT_NAME]}-#{@ie_caches[LON_NAME]}"
          cell_infos.each do |cell_info|
            SpanReport.logger.debug "cell info is:#{cell_info.cell_name}-#{cell_info.pci}-#{cell_info.freq}-#{cell_info.lat}-#{cell_info.lon}"
            cell_point = Point.new cell_info.lat, cell_info.lon
            dis = point.distance cell_point
            if min_dis.nil? || dis < min_dis
              min_dis = dis
              near_cell_info = cell_info
            end
          end
          SpanReport.logger.debug "near cell info is:#{near_cell_info.cell_name}-#{near_cell_info.pci}-#{near_cell_info.freq}-#{near_cell_info.lat}-#{near_cell_info.lon}"

          nodeb_name = near_cell_info.nodeb_name if near_cell_info
          cell_name = near_cell_info.cell_name if near_cell_info
          @last_nodeb = nodeb_name
          @last_cell = cell_name

          @relate_nodebs << nodeb_name
        else
          @last_nodeb = ""
          @last_cell = ""
        end
      end

      @last_pci_freq_key = pci_freq_key

      if cell_name != ""
        nodeb_counter_name = "#{nodeb_name}$#{counter_name}"
        cell_counter_name = "#{cell_name}$#{counter_name}"
        super nodeb_counter_name, counter_ievalue, count_mode, pctime, is_valid
        super cell_counter_name, counter_ievalue, count_mode, pctime, is_valid
      end
      
    end

    def add_nodeb_cell_info cell_infos
      reg_cell_pci_freq_iename
      cell_infos.each do |cell_info|
        nodeb_name = cell_info.nodeb_name
        cell_name = cell_info.cell_name
        pci = cell_info.pci.to_i
        freq = cell_info.freq.to_i

        @pci_freq_map["#{pci}_#{freq}"] ||= []
        @pci_freq_map["#{pci}_#{freq}"] << cell_info
      end
      SpanReport.logger.debug "@pci_freq_map is:#{@pci_freq_map.inspect}"
    end

    def reg_cell_pci_freq_iename
      reg_iename PCI_IENAME, PCI_IENAME
      reg_iename FREQ_IENAME, FREQ_IENAME
      reg_iename LAT_NAME, LAT_NAME
      reg_iename LON_NAME, LON_NAME
    end

    class Point
      attr_reader :lat, :lon

      def initialize(lat, lon)
        @lat = lat.to_f
        @lon = lon.to_f
      end

      def distance point
         lng1 = @lon
         lat1 = @lat
         lng2 = point.lon
         lat2 = point.lat
         rad = Math::PI / 180.0
         earth_radius = 6378.137 * 1000 #地球半径
         radLat1 = lat1 * rad
         radLat2 = lat2 * rad
         a = radLat1 - radLat2
         b = (lng1 - lng2) * rad
         s = 2 * Math.asin(Math.sqrt( (Math.sin(a/2)**2) + Math.cos(radLat1) * Math.cos(radLat2)* (Math.sin(b/2)**2) ))
         s = s * earth_radius
         s = (s * 10000).round / 10000
         SpanReport.logger.debug "distance is:#{s}"
         s
      end

    end

  end
end