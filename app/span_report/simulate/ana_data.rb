#encoding: utf-8

# 模拟使用的分析数据
# 1. 需要以时间进行合并
# 2. 以邻小区数据有效作为过滤条件
# 3. 其他点进行补齐
# 4. 根据路测数据，补充分析需要的数据，例如小区名，与小区的距离
# 5. 提供根据条件数据筛选的方法
# 6. 提供根据场强，排序的方法

module SpanReport::Simulate

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

  # 分析需要的数据，时间，UE，主服务小区和邻区信息
  # 这里主服务小区和邻区是没有本质上的区别，数据信息也是一样的
  # 小区的数据信息是：小区PCI，Freq，名称，距离，RSRP，SINR
  class AnaData
    attr_accessor :point_datas, :cell_infos, :ie_caches

    def initialize
      @point_datas = []
      @last_point_data = nil
      @holdlast_data = HoldlastData.new
      @cell_infos = nil
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
        if @last_point_data.valid?
          @last_point_data.fill @holdlast_data
          @last_point_data.fill_extra @cell_infos
          @last_point_data.sort_cells
          @point_datas << @last_point_data
        end
        @last_point_data = point_data
      end
    end

    def to_file
      File.open("simulate.csv", "w") do |file|
        file.write 'EF BB BF'.split(' ').map{|a|a.hex.chr}.join()
        headstring = "time,ue,#{LAT},#{LON},#{SCELL_PCI},#{SCELL_FREQ},#{SCELL_RSRP},#{SCELL_SINR},#{SCELL_NAME},#{SCELL_DISTANCE}"
        (0..ANA_NCELL_NUM-1).each do |i|
          headstring = "#{headstring},#{NCELL_PCI}_#{i},#{NCELL_FREQ}_#{i},#{NCELL_RSRP}_#{i},#{NCELL_NAME}_#{i},#{NCELL_DISTANCE}_#{i}"
        end
        file.puts headstring
        @point_datas.each do |point_data|
          rowdata_string = ""
          rowdata_string <<  "#{point_data.time.to_s},"
          rowdata_string <<  "#{point_data.ue.to_s},"
          rowdata_string <<  "#{point_data.lat.to_s},"
          rowdata_string <<  "#{point_data.lon.to_s},"
          rowdata_string <<  "#{point_data.serve_cell.pci.to_s},"
          rowdata_string <<  "#{point_data.serve_cell.freq.to_s},"
          rowdata_string <<  "#{point_data.serve_cell.rsrp.to_s},"
          rowdata_string <<  "#{point_data.serve_cell.sinr.to_s},"
          rowdata_string <<  "#{point_data.serve_cell.cell_name.to_s},"
          rowdata_string <<  "#{point_data.serve_cell.distance.to_s},"
          point_data.nei_cells.each do |ncell|
            rowdata_string <<  "#{ncell.pci.to_s},"
            rowdata_string <<  "#{ncell.freq.to_s},"
            rowdata_string <<  "#{ncell.rsrp.to_s},"
            rowdata_string <<  "#{ncell.cell_name.to_s},"
            rowdata_string <<  "#{ncell.distance.to_s},"
          end
          file.puts rowdata_string
        end
      end
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

  class PointData
    attr_accessor :time, :ue, :lat, :lon, :serve_cell, :nei_cells
    attr_reader :data_map

    def initialize(time, ue, data_map={})
      @time = time
      @ue = ue
      @data_map = data_map
      @data_map ||= {}
    end

    def merge? other_data
      @time == other_data.time && @ue == other_data.ue
    end

    def merge! other_data
      @data_map.merge! other_data.data_map
    end

    def fill holdlast_data
      @lat = holdlast_data.lat if @lat.nil? && holdlast_data.lat
      @lon = holdlast_data.lon if @lon.nil? && holdlast_data.lon
      if (@serve_cell.nil? || @serve_cell.pci.nil?) && holdlast_data.pci
        @serve_cell ||= CellData.new
        @serve_cell.pci = holdlast_data.pci
      end
      if (@serve_cell.nil? || @serve_cell.freq.nil?) && holdlast_data.freq
        @serve_cell ||= CellData.new
        @serve_cell.freq = holdlast_data.freq
      end
      if (@serve_cell.nil? || @serve_cell.rsrp.nil?) && holdlast_data.rsrp
        @serve_cell ||= CellData.new
        @serve_cell.rsrp = holdlast_data.rsrp
      end
      if (@serve_cell.nil? || @serve_cell.sinr.nil?) && holdlast_data.sinr
        @serve_cell ||= CellData.new
        @serve_cell.sinr = holdlast_data.sinr
      end
    end

    def fill_extra cell_infos
      gps_point = Point.new @lat, @lon
      @serve_cell.fill_cell_extra gps_point, cell_infos

      @nei_cells.each do |nei_cell|
        nei_cell.fill_cell_extra gps_point, cell_infos
      end

    end

    def expand_data
      @lat = @data_map[LAT]
      @lon = @data_map[LON]
      @serve_cell = CellData.new
      if @data_map[SCELL_PCI]
        @serve_cell = CellData.new(@data_map[SCELL_PCI], @data_map[SCELL_FREQ])
        @serve_cell.rsrp = @data_map[SCELL_RSRP]
        @serve_cell.sinr = @data_map[SCELL_SINR]
      end

      @nei_cells = []
      (0..ANA_NCELL_NUM-1).each do |i|
        if @data_map["#{NCELL_PCI}_#{i}"]
          pci = @data_map["#{NCELL_PCI}_#{i}"]
          freq = @data_map["#{NCELL_FREQ}_#{i}"]
          nei_cell =  CellData.new(pci, freq)
          nei_cell.rsrp = @data_map["#{NCELL_RSRP}_#{i}"]
          @nei_cells << nei_cell
        end
      end
      # 清空内存
      data_map = {}
    end

    # 根据场强，重新进行邻区排列
    def sort_cells
      cell_datas = []
      cell_datas << @serve_cell if @serve_cell && @serve_cell.rsrp

      if @nei_cells
        @nei_cells.each do |celldata|
          cell_datas << celldata
        end
      end

      bubble_sort cell_datas

      unless cell_datas.empty?
        @serve_cell = cell_datas[0]
        @nei_cells = []
        (1..cell_datas.size-1).each do |i|
          @nei_cells << cell_datas[i]
        end
      end
    end

    def bubble_sort(cell_datas)
      (cell_datas.size-2).downto(0) do |i|
        (0..i).each do |j|  
          if cell_datas[j].rsrp.to_f < cell_datas[j+1].rsrp.to_f
            cell_datas[j], cell_datas[j+1] = cell_datas[j+1], cell_datas[j]
          end
        end
      end  
      return cell_datas
    end

    # 认为有邻区的数据才是有效的
    def valid?
      @nei_cells && !@nei_cells.empty?
    end
  end
  

  # 主小区或者邻小区的数据类
  # 里面填充了分析需要的小区名、距离等内容
  class CellData
    attr_accessor :pci, :freq, :nodeb_name, :cell_name, 
                :distance, :rsrp, :sinr

    def initialize pci=nil, freq=nil
      @pci = pci.to_i if pci
      # @freq = freq
      if (freq.to_i == 38350)
        @freq = 1890
      else
        @freq = freq.to_i if freq
      end
    end

    def freq= freq
      if (freq.to_i == 38350)
        @freq = 1890
      else
        @freq = freq.to_i
      end
    end

    # 提供根据小区基站信息，查找pci和freq相同，距离最近的小区
    # 把相关的信息增加在cell data里
    def fill_cell_extra data_point, cell_infos
      relate_cell_infos = cell_infos.get_cellinfos @pci, @freq

      # 查找pci和freq相同中，最近的小区
      min_dis = nil
      near_cell_info = nil
      # puts "pci is:#{pci}, freq is:#{freq}, relate_cell_infos size is:#{relate_cell_infos.size}"
      relate_cell_infos.each do |cell_info|
        cell_point = Point.new cell_info.lat, cell_info.lon
        dis = data_point.distance cell_point
        if min_dis.nil? || dis < min_dis
          min_dis = dis
          near_cell_info = cell_info
        end
      end

      if near_cell_info
        @nodeb_name = near_cell_info.nodeb_name
        @cell_name = near_cell_info.cell_name
        @distance = min_dis
      end
    end

  end

  class Point
    attr_reader :lat, :lon

    def initialize(lat, lon)
      @lat = lat.to_f
      @lon = lon.to_f
    end

    def distance point
      begin
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
      rescue Exception => e
        s = 99999999
      end
      s
    end
  end

end