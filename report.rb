# encoding: utf-8

require 'pathname'
require_relative "app/span_report"


#遍历文件夹下指定类型的文件
# def list_files(file_path, file_types)
#   files = []
#   if (File.directory? file_path)
#     Dir.foreach(file_path) do |file|
#       file_types.each do |file_type|
#         if file=~/.#{file_type}$/
#           files << "#{file_path}/#{file}"
#         end
#       end
#     end
#   end
#   files
# end

# Dir.chdir File.dirname __FILE__
# path = Pathname.new(File.dirname(__FILE__)).realpath
path = Dir.getwd
puts "working path is: #{path}"
###########################
#读取counter model
###########################
counter_model = SpanReport::Model::CounterModel.new
counter_model.parse "#{path}/config/counter_define.xlsx"

###########################
#读取系统其他的配置文件
##########################
config_map = {}
File.foreach("config/config.ini") do |line|
  line.chop!
  contents = line.split ':'
  config_map[contents[0]] = contents[1] unless contents[0].empty?
end

###########################
#读入报表模板
###########################
templatefile = "#{path}/config/OuterData.xlsx"
excel_export = SpanReport::Process::ReportExport.new(templatefile)

###########################
#读取日志，处理日志
###########################
SpanReport::Model::Logformat.instance.load_xml "config/LogFormat_100.xml"
report = SpanReport::Process::Report.new

counter_model.counter_items.each do |counter_item|
  report.reg_counter_item counter_item
end

counter_model.kpi_items.each do |kpi_item|
  report.reg_kpi_item kpi_item
end

logfiles = SpanReport.list_files("./log", ["lgl"])

#多个日志合并导出
if config_map["combine"] == "true"
  begin
    filereader = SpanReport::Logfile::FileReader.new logfiles
    filereader.parse(report)
    report.count_kpi_value
    resultfile = "#{path}/log/combine.report.xlsx"
    excel_export.to_excel resultfile, report

    report.clear
  rescue Exception => e
    puts e
  ensure
    filereader.clear_files
  end
# 日志分别导出
else
  logfiles.each do |logfile|
    begin
      filereader = SpanReport::Logfile::FileReader.new [logfile]
      filereader.parse(report)
      report.count_kpi_value
      resultfile = "#{path}/#{logfile}"
      resultfile = resultfile.sub('lgl', 'report.xlsx')
      SpanReport.logger.debug "resultfile is: #{resultfile}"

      excel_export.to_excel resultfile, report
      
      report.clear
    rescue Exception => e
      next
    ensure
      filereader.clear_files
    end
  end
end

###########################
#生成报表结果文件
###########################