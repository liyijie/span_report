# encoding: utf-8

module SpanReport::Context
  class NodebReportContext < BaseContext
    attr_reader :cell_info, :counter_def, :outer_def

    def load_relate
      doc = Nokogiri::XML(open(CONFIG_FILE))
      doc.search(@function).each do |relate|
        @cell_info = get_content relate, "cell_info"
        @counter_def = get_content relate, "counter_def"
        @outer_def = get_content relate, "outer_def"
      end
    end

    def process
      SpanReport::Model::Logformat.instance.load_xml "config/LogFormat_100.xml"

      excel_export = SpanReport::Process::NodebReportExport.new @outer_def
      excel_export.load_cell_infos @cell_info

      report = SpanReport::Process::NodebReport.new

      counter_model = SpanReport::Model::CounterModel.new
      counter_model.parse @counter_def
      #counter配置
      counter_model.counter_items.each do |counter_item|
        report.reg_counter_item counter_item
      end
      #kpi配置
      counter_model.kpi_items.each do |kpi_item|
        report.reg_kpi_item kpi_item
      end
      #小区表信息
      report.add_nodeb_cell_info(excel_export.cell_infos)

      logfiles = SpanReport.list_files(@input_log, ["lgl"])
      begin
        filereader = SpanReport::Logfile::FileReader.new logfiles
        filereader.parse(report)
        report.count_kpi_value
        result_path = @output_log
        excel_export.to_excels result_path, report

        report.clear
      rescue Exception => e
        puts e
      ensure
        filereader.clear_files
      end
    end


  end
end