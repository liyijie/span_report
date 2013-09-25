#encoding: utf-8

# 模拟使用的分析数据
# 1. 需要以时间进行合并
# 2. 以邻小区数据有效作为过滤条件
# 3. 其他点进行补齐
# 4. 根据路测数据，补充分析需要的数据，例如小区名，与小区的距离
# 5. 提供根据条件数据筛选的方法
# 6. 提供根据场强，排序的方法

module SpanReport::Simulate

  # 分析需要的数据，时间，UE，主服务小区和邻区信息
  # 这里主服务小区和邻区是没有本质上的区别，数据信息也是一样的
  # 小区的数据信息是：小区PCI，Freq，名称，距离，RSRP，SINR
  class AnaData
    attr_accessor :point_datas, :cell_infos

    def initialize cell_infos=nil
      @point_datas = []
      @last_point_data = nil
      @holdlast_data = HoldlastData.new
      @cell_infos = cell_infos
    end
    
    
  end

  class PointData
    attr_accessor :time, :ue, :lat, :lon, :dl_th, :pci, :freq, :rsrp, :sinr, :cell_name, :serve_cell, :nei_cells
    attr_accessor :over_range_count, :disturb, :effect_sinr, :rsrp_delta
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

    def expand_celldatas
      celldatas = []

      scell_data = PointData.new(@time, @ue)
      scell_data.lat = lat
      scell_data.lon = lon
      scell_data.pci = pci
      scell_data.freq = freq
      scell_data.rsrp = rsrp
      scell_data.sinr = sinr
      scell_data.cell_name = cell_name
      scell_data.effect_sinr = effect_sinr
      scell_data.over_range_count = over_range_count
      celldatas << scell_data

      @nei_cells.each do |nei_cell|
        nei_celldata = PointData.new(@time, @ue)
        nei_celldata.lat = lat
        nei_celldata.lon = lon
        nei_celldata.pci = nei_cell.pci
        nei_celldata.freq = nei_cell.freq
        nei_celldata.rsrp = nei_cell.rsrp
        nei_celldata.cell_name = nei_cell.cell_name
        nei_celldata.rsrp_delta = nei_cell.rsrp_delta
        nei_celldata.effect_sinr = effect_sinr
        nei_celldata.over_range_count = over_range_count
        celldatas << nei_celldata
      end

      celldatas
    end

    def fill holdlast_data
      @lat = holdlast_data.lat if @lat.nil? && holdlast_data.lat
      @lon = holdlast_data.lon if @lon.nil? && holdlast_data.lon
      # @dl_th = holdlast_data.dl_th if @dl_th.nil? && holdlast_data.dl_th

      if (@serve_cell.nil? || @serve_cell.pci.nil?) && holdlast_data.pci
        @serve_cell ||= CellData.new
        @serve_cell.pci = holdlast_data.pci
        @pci = holdlast_data.pci
      end
      if (@serve_cell.nil? || @serve_cell.freq.nil?) && holdlast_data.freq
        @serve_cell ||= CellData.new
        @serve_cell.freq = holdlast_data.freq
        @freq = holdlast_data.freq
      end
      if (@serve_cell.nil? || @serve_cell.rsrp.nil?) && holdlast_data.rsrp
        @serve_cell ||= CellData.new
        @serve_cell.rsrp = holdlast_data.rsrp
        @rsrp = holdlast_data.rsrp
      end
      if (@serve_cell.nil? || @serve_cell.sinr.nil?) && holdlast_data.sinr
        @serve_cell ||= CellData.new
        @serve_cell.sinr = holdlast_data.sinr
        @sinr = holdlast_data.sinr
      end
    end

    ###########################################
    # 填充小区的友好名和距离等信息
    ###########################################
    def fill_extra cell_infos
      return unless @cell_name.to_s.empty?
      return if @serve_cell.nil?
      gps_point = Point.new @lat, @lon
      @serve_cell.fill_cell_extra gps_point, cell_infos
      @cell_name = @serve_cell.cell_name

      @nei_cells.each do |nei_cell|
        nei_cell.fill_cell_extra gps_point, cell_infos
      end

    end

    ###########################################
    # 把map里的内容展开，然后放到相应的属性中
    ###########################################
    def expand_data
      @lat = @data_map[LAT]
      @lon = @data_map[LON]
      @dl_th = @data_map[DL_TH]

      @serve_cell = CellData.new
      if @data_map[SCELL_PCI] || @data_map[SCELL_FREQ] || @data_map[SCELL_RSRP] || @data_map[SCELL_SINR]
        @serve_cell = CellData.new(@data_map[SCELL_PCI], @data_map[SCELL_FREQ])
        @serve_cell.rsrp = @data_map[SCELL_RSRP]
        @serve_cell.sinr = @data_map[SCELL_SINR]
        @serve_cell.cell_name = @data_map[SCELL_NAME].encode('utf-8') if @data_map[SCELL_NAME]
        @serve_cell.distance = @data_map[SCELL_DISTANCE]
        @pci = @data_map[SCELL_PCI]
        @freq = @data_map[SCELL_FREQ]
        @rsrp = @data_map[SCELL_RSRP]
        @sinr = @data_map[SCELL_SINR]
        @cell_name = @data_map[SCELL_NAME]
      # else
        # puts "no pci info, data_map is:#{@data_map.inspect}"
      end

      @nei_cells = []
      (0..ANA_NCELL_NUM-1).each do |i|
        if @data_map["#{NCELL_PCI}_#{i}"] && @data_map["#{NCELL_PCI}_#{i}"].to_i > 0
          pci = @data_map["#{NCELL_PCI}_#{i}"]
          freq = @data_map["#{NCELL_FREQ}_#{i}"]
          nei_cell =  CellData.new(pci, freq)
          nei_cell.rsrp = @data_map["#{NCELL_RSRP}_#{i}"]
          nei_cell.cell_name = @data_map["#{NCELL_NAME}_#{i}"].encode('utf-8') if @data_map["#{NCELL_NAME}_#{i}"]
          nei_cell.distance = @data_map["#{NCELL_DISTANCE}_#{i}"]
          @nei_cells << nei_cell
        end
      end
      # 清空内存
      @data_map = {}
    end

    def fill_kpi_data config_map
      PointKpiProcess.process_pointdata self, config_map
    end

    def filter_distance config_map, filter_map={}

      if @serve_cell.distance.to_f > config_map[DISTANCE_FILTER].to_f
        @serve_cell.rsrp = -140
        @rsrp = -140
      end

      if filter_map.has_key? @serve_cell.cell_name
        if (@serve_cell.distance.to_f > filter_map[@serve_cell.cell_name].distance.to_f)
          @serve_cell.rsrp = -140
          @rsrp = -140
        end
      end

      @nei_cells.each do |nei_cell|
        if (nei_cell.distance.to_f > config_map[DISTANCE_FILTER].to_f)
          nei_cell.rsrp = -140
        end

        if filter_map.has_key? nei_cell.cell_name
          if (nei_cell.distance.to_f > filter_map[nei_cell.cell_name].distance.to_f)
            nei_cell.rsrp = -140
          end
        end
      end
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

      @serve_cell = cell_datas[0]
      if @serve_cell
        @pci = cell_datas[0].pci
        @freq = cell_datas[0].freq
        @rsrp = cell_datas[0].rsrp
        @sinr = cell_datas[0].sinr
        @cell_name = cell_datas[0].cell_name
      end

      unless cell_datas.empty?
        @nei_cells = []
        (1..cell_datas.size-1).each do |i|
          @nei_cells << cell_datas[i]
        end
      end
    end

    def bubble_sort(cell_datas)
      return if cell_datas.empty?

      # cell_datas = cell_datas.sort_by do |cell_data|
      #   cell_data.rsrp.to_f * (-1)
      # end
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

    def to_s
      rowdata_string = ""
      rowdata_string <<  "#{@time.to_s},"
      rowdata_string <<  "#{@ue.to_s},"
      rowdata_string <<  "#{@lat.to_s},"
      rowdata_string <<  "#{@lon.to_s},"
      rowdata_string <<  "#{@serve_cell.pci.to_s},"
      rowdata_string <<  "#{@serve_cell.freq.to_s},"
      rowdata_string <<  "#{@serve_cell.rsrp.to_s},"
      rowdata_string <<  "#{@serve_cell.sinr.to_s},"
      rowdata_string <<  "#{@serve_cell.cell_name.to_s},"
      rowdata_string <<  "#{@serve_cell.distance.to_s},"
      (0..ANA_NCELL_NUM-1).each do |index|
        ncell = @nei_cells[index]
        if ncell
          rowdata_string <<  "#{ncell.pci.to_s},"
          rowdata_string <<  "#{ncell.freq.to_s},"
          rowdata_string <<  "#{ncell.rsrp.to_s},"
          rowdata_string <<  "#{ncell.cell_name.to_s},"
          rowdata_string <<  "#{ncell.distance.to_s},"
        else
          rowdata_string <<  ","
          rowdata_string <<  ","
          rowdata_string <<  ","
          rowdata_string <<  ","
          rowdata_string <<  ","
        end
      end
      
      rowdata_string << "#{@effect_sinr.to_s},"
      rowdata_string << "#{@dl_th.to_s},"
      rowdata_string << "#{@over_range_count.to_s}"
      rowdata_string 
    end

    def self.head_string
      headstring = "time,ue,#{LAT},#{LON},#{SCELL_PCI},#{SCELL_FREQ},#{SCELL_RSRP},#{SCELL_SINR},#{SCELL_NAME},#{SCELL_DISTANCE}"
      (0..ANA_NCELL_NUM-1).each do |i|
        headstring = "#{headstring},#{NCELL_PCI}_#{i},#{NCELL_FREQ}_#{i},#{NCELL_RSRP}_#{i},#{NCELL_NAME}_#{i},#{NCELL_DISTANCE}_#{i}"
      end
      headstring = "#{headstring},E-SINR"
      headstring = "#{headstring},#{DL_TH}"
      headstring = "#{headstring},over_range_count"
      headstring
    end

  end
  

  # 主小区或者邻小区的数据类
  # 里面填充了分析需要的小区名、距离等内容
  class CellData
    attr_accessor :pci, :freq, :nodeb_name, :cell_name, 
                :distance, :rsrp, :sinr
    attr_accessor :rsrp_delta

    def initialize pci=nil, freq=nil
      @pci = pci.to_i if !pci.to_s.empty?
      @freq = convert_freq freq if !freq.to_s.empty?
    end

    def freq= freq
      @freq = convert_freq freq
    end

    def convert_freq freq

      ifreq = freq.to_i
      if (ifreq >= 37750 && ifreq <= 38249)
        flow = 2570
        offset = 37750
      elsif (ifreq >= 38250 && ifreq <= 38649)
        flow = 1880
        offset = 38250
      elsif (ifreq >= 38650 && ifreq <= 39649)
        flow = 2300
        offset = 38650
      end

      if flow
        freq_rlt = flow + (ifreq - offset) / 10
      else
        freq_rlt = ifreq if freq
      end
      freq_rlt
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
      else
        @cell_name = @pci.to_s
        @distance = 9999
      end
    end

    def to_s
      "#{pci},#{freq},#{nodeb_name},#{cell_name},#{distance},#{rsrp},#{sinr}"
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