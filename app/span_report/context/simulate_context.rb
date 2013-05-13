# encoding: utf-8

module SpanReport::Context
  class SimulateContext < BaseContext

    SOURCE_CSV = "sourcedata.csv"

    def initialize path
      super
      @filter_map = {}
      @is_temp = false
    end

    def load_relate
      doc = Nokogiri::XML(open(CONFIG_FILE))
      doc.search(@function).each do |relate|
        @cell_info = get_content relate, "cell_info"
        puts "cell is : #{@cell_info}"
        @config_map = {}
        relate.search("threshold").each do |threshold|
          threshold_name = threshold.get_attribute("name")
          threshold_value = threshold.get_attribute("value")
          @config_map[threshold_name] = threshold_value
        end
      end
      @cell_infos = SpanReport::Simulate::CellInfos.new
      @cell_infos.load_from_xls @cell_info
    end
    
    def process
      SpanReport::Model::Logformat.instance.load_xml "config/LogFormat_100.xml"

      #####################
      # 原始值
      #####################
      # lgl转csv文件
      csv_file = lgl_to_csv


      #####################
      # 第1次
      #####################    
      folder = File.join @output_log, "第1次"
      Dir.mkdir(folder) unless File.exist?(folder)
      kpiresult = simulate_csv csv_file, folder, @is_temp
      worst_cellname = kpiresult.worst_cellname
      effectsinr = kpiresult.effectsinr.to_f
      overrange = kpiresult.overrange
      
      @last_effectsinr = -999
      @overrange = 0


      #####################
      # 第2次 - 第n次
      #####################
      index = 1
      result_file = File.join @output_log, "result.txt"
      file = File.new(result_file, 'w')
      while effectsinr > @last_effectsinr
        @last_effectsinr = effectsinr
        @overrange = overrange
        caculate_filter @filter_map, worst_cellname

        csv_file = File.join @output_log, "第#{index}次", SOURCE_CSV
        folder = File.join @output_log, "第#{index+1}次"
        Dir.mkdir(folder) unless File.exist?(folder)
        kpiresult = simulate_csv csv_file, folder

        effectsinr = kpiresult.effectsinr
        worst_cellname = kpiresult.worst_cellname
        overrange = kpiresult.overrange



        file.puts "======================第#{index}次==========================================".encode('GBK')
        @filter_map.each do |cell_name, filterinfo|
          file.puts filterinfo.to_s.encode('GBK')
        end
        file.puts "调整后等效SINR是:#{effectsinr}, 调整前等效SINR是:#{@last_effectsinr}".encode('GBK')
        file.puts "调整后过覆盖系数是:#{overrange}, 调整前过覆盖系数是:#{@overrange}".encode('GBK')
        file.puts "干扰强度最大小区: #{worst_cellname.to_s.encode('utf-8')}".encode('GBK')
        puts "============================================================================="

        index += 1
      end
      file.close

    end

    protected

    # 先在filter map里查找
    # 如果找不到，再去小区信息里查找
    def caculate_filter filter_map, cell_name
      if filter_map.has_key? cell_name
        filterinfo = filter_map[cell_name]
        filterinfo.angle += 2
        filterinfo.caculate
      elsif @cell_infos.get_cellinfo cell_name
        temp_cell_info = @cell_infos.get_cellinfo cell_name
        filterinfo = FilterInfo.new
        filterinfo.cell_name = temp_cell_info.cell_name
        filterinfo.high = temp_cell_info.high.to_f
        filterinfo.angle = temp_cell_info.angle.to_f + 2
        filterinfo.caculate
        filter_map[cell_name] = filterinfo
      end
    end

    ###################################################
    # lgl转csv文件
    # 1. lgl读取
    # 2. 判断数据是否需要
    # 3. 填充小区信息（所属小区名称，距离）
    # 4. 生成本次CSV
    ###################################################
    def lgl_to_csv 

      folder = File.join @output_log, "原始值"
      Dir.mkdir(folder) unless File.exist?(folder)
      csv_file = File.join folder, SOURCE_CSV
      convert_file_process = SpanReport::Simulate::ConvertFileProcess.new csv_file, @config_map, @cell_infos

      logfiles = SpanReport.list_files(@input_log, ["lgl"])
      # begin
        filereader = SpanReport::Logfile::FileReader.new logfiles
        filereader.parse(convert_file_process)
      # rescue Exception => e
      #   puts e
      # ensure
        filereader.clear_files
        convert_file_process.close_file
      # end
      csv_file
    end

    ###################################################
    # 1. 读取csv文件          每一行读取一个PointData
    # 2. 根据过滤条件过滤点（模拟调整，这里的调整过程是叠加的）PointData
    # 3. 主服务小区和邻小区排序 PointData
    # 4. 生成本次CSV          Processor
    # 5. 计算每个点的KPI       PointData
    # 6. 计算每个小区的KPI     Processor
    # 7. 生成地图图层          Processor
    # 8. 生成报表             Processor
    ###################################################
    def simulate_csv input_csv_file, output_folder, is_temp=false
      fileinfo = SpanReport::FileInfo.new input_csv_file, ""
      csvfiles = [fileinfo]
      csv_reader = SpanReport::Logfile::CsvReader.new csvfiles, is_temp

      processers = []
      simulate_process = SpanReport::Simulate::SimulateProcess.new @config_map, @filter_map
      processers << simulate_process
      cellkpi_process = SpanReport::Simulate::CellKpiProcess.new @config_map
      # cellkpi_process = SpanReport::Simulate::CellKpiProcessByService.new @config_map
      processers << cellkpi_process

      map_output_folder = File.join output_folder, "map"
      Dir.mkdir(map_output_folder) unless File.exist?(map_output_folder)
      map_process = SpanReport::Map::MapProcess.new map_output_folder
      processers << map_process
      cellmap_process = SpanReport::Map::CellMapProcess.new map_output_folder, @cell_infos
      processers << cellmap_process

      output_csv_file = File.join output_folder, SOURCE_CSV
      convert_file_process = SpanReport::Simulate::ConvertFileProcess.new output_csv_file, @config_map, @cell_infos
      processers << convert_file_process

      csv_reader.parse processers

      map_process.close_file
      cellmap_process.close_file
      convert_file_process.close_file

      kpiresult = KpiResult.new
      cellkpi_process.cal_kpi_value
      kpiresult.worst_cellname = cellkpi_process.worst_cell_name
      kpiresult.effectsinr = cellkpi_process.effectsinr_kpi.value
      kpiresult.overrange = cellkpi_process.overrange_kpi.value

      cellkpi_process.to_file(File.join(output_folder, "kpi.csv"))

      kpiresult
    end
  end

  class KpiResult
    attr_accessor :worst_cellname, :effectsinr, :overrange
  end

  class FilterInfo
    attr_accessor :cell_name, :high, :angle, :distance

    def caculate
      @distance = @high.to_f * Math.tan((90-@angle)*Math::PI/180) + 50
      # @distance = 0
    end

    def to_s
      "小区名:#{@cell_name.encode('utf-8')}, 挂高:#{@high}, 下倾角:#{@angle}, 覆盖距离:#{distance}"
    end
  end
  
end