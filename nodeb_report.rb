# encoding: utf-8

require 'pathname'
require_relative "app/span_report"

path = Dir.getwd
puts "working path is: #{path}"

###########################
#读取counter model
###########################
counter_model = SpanReport::Model::CounterModel.new
counter_model.parse "#{path}/config/counter_define.xlsx"

###########################
#读入报表模板
###########################
templatefile = "#{path}/config/OuterData.xlsx"
excel_export = SpanReport::Process::NodebReportExport.new(templatefile)
excel_export.load_cell_infos "#{path}/config/基站小区表.xlsx"


##########################
#读取日志，处理日志
###########################
SpanReport::Model::Logformat.instance.load_xml "config/LogFormat_100.xml"
report = SpanReport::Process::NodebReport.new

counter_model.counter_items.each do |counter_item|
  report.reg_counter_item counter_item
end

counter_model.kpi_items.each do |kpi_item|
  report.reg_kpi_item kpi_item
end
report.add_nodeb_cell_info(excel_export.cell_infos)

logfiles = SpanReport.list_files("./log", ["lgl"])
begin
  filereader = SpanReport::Logfile::FileReader.new logfiles
  filereader.parse(report)
  report.count_kpi_value
  result_path = "#{path}/log"
  excel_export.to_excels result_path, report

  report.clear
rescue Exception => e
  puts e
ensure
  filereader.clear_files
end
