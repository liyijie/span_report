# encoding: utf-8

module SpanReport::Context
  class MapContext < BaseContext

    def load_relate
      doc = Nokogiri::XML(open(CONFIG_FILE))
      doc.search(@function).each do |relate|
        @cell_info = get_content relate, "cell_info"
      end
    end

    def process
      SpanReport::Model::Logformat.instance.load_xml "config/LogFormat_100.xml"

      # 如果是lgl，先在目录下转换成我们需要使用的中间文件
      logfiles = SpanReport.list_files(@input_log, ["lgl"])
      csv_file = convert_lgl_to_csv logfiles if !logfiles.empty?

      csvfiles = SpanReport.list_files(@input_log, ["csv"])
      csv_reader = SpanReport::Logfile::CsvReader.new csvfiles

      processers = []
      map_process = SpanReport::Map::MapProcess.new
      map_process.config_export_file(File.join(@output_log, "combine.map.csv"))
      processers << map_process
      csv_reader.parse processers
      map_process.flush

    end

    def convert_lgl_to_csv logfiles
      cell_infos = SpanReport::Simulate::CellInfos.new
      cell_infos.load_from_xls @cell_info

      convert_file_process = SpanReport::Simulate::ConvertFileProcess.new
      convert_file_process.set_cellinfos cell_infos

      filereader = SpanReport::Logfile::FileReader.new logfiles
      filereader.parse convert_file_process
      csv_file = File.join @input_log, "combine.csv"
      convert_file_process.to_file csv_file

      csv_file
    end
  end
end