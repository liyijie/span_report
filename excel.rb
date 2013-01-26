# encoding: utf-8

require 'pathname'
require_relative "app/span_report"


#遍历文件夹下指定类型的文件
def list_files(file_path, file_types)
  files = []
  if (File.directory? file_path)
    Dir.foreach(file_path) do |file|
      file_types.each do |file_type|
        if file=~/.#{file_type}$/
          files << "#{file_path}/#{file}"
        end
      end
    end
  end
  files
end

path = Pathname.new(File.dirname(__FILE__)).realpath
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
#读取日志，处理日志
###########################
SpanReport::Model::Logformat.instance.load_xml "config/LogFormat_100.xml"
report = SpanReport::Process::Report.new

counter_model.counter_items.each do |counter_item|
  report.reg_counter_item counter_item
end

logfiles = list_files("./log", ["lgl"])

#多个日志合并导出
if config_map["combine"] == "true"
  begin
    filereader = SpanReport::Logfile::FileReader.new logfiles
    filereader.parse(report)
    resultfile = "#{path}/log/combine.xlsx"
    templatefile = "#{path}/config/OuterData.xlsx"
    excel_export = SpanReport::Process::Report::ReportExport.new(templatefile)
    excel_export.to_excel resultfile, report
  rescue Exception => e
    puts e
  ensure
    filereader.clear_files
  end
#日志分别导出
# else
#   logfiles.each do |logfile|
#     begin
#       filereader = SpanReport::Logfile::FileReader.new [logfile]
#       filereader.parse(export)
#       resultfile = logfile.sub('lgl', 'csv')
#       export.write_result(resultfile)
#     rescue Exception => e
#       puts e.message
#     ensure
#       filereader.clear_files
#     end
#   end
end

###########################
#读入报表模板
###########################

###########################
#生成报表结果文件
###########################