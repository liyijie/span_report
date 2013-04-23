# encoding: utf-8

module SpanReport::Context
  class MapContext < BaseContext

    attr_reader :cell_infos

    def load_relate
      doc = Nokogiri::XML(open(CONFIG_FILE))
      doc.search(@function).each do |relate|
        @cell_info = get_content relate, "cell_info"
      end
    end

    def process
      SpanReport::Model::Logformat.instance.load_xml "config/LogFormat_100.xml"
      @cell_infos = SpanReport::Simulate::CellInfos.new
      @cell_infos.load_from_xls @cell_info
      
      # 如果是lgl，先在目录下转换成我们需要使用的中间文件
      logfiles = SpanReport.list_files(@input_log, ["lgl"])
      csv_file = convert_lgl_to_csv logfiles if !logfiles.empty?

      csvfiles = SpanReport.list_files(@input_log, ["csv"])
      csv_reader = SpanReport::Logfile::CsvReader.new csvfiles

      processers = []
      map_process = SpanReport::Map::MapProcess.new @output_log
      # map_process.config_export_file(File.join(@output_log, "全部轨迹.csv"))
      processers << map_process

      cell_map_process = SpanReport::Map::CellMapProcess.new @output_log, @cell_infos
      processers << cell_map_process

      csv_reader.parse processers
      map_process.close_file
      cell_map_process.close_file
    end

    def convert_lgl_to_csv logfiles
      csv_file = File.join @input_log, "combine.csv"
      convert_file_process = SpanReport::Simulate::ConvertFileProcess.new csv_file, @cell_infos
      
      filereader = SpanReport::Logfile::FileReader.new logfiles
      filereader.parse convert_file_process

      filereader.clear_files

      csv_file
    end
  end
end