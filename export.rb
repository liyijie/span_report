# encoding: utf-8

require_relative "app/span_report"

def export(log_path)
  SpanReport::Model::Logformat.instance.load_xml "config/LogFormat_100.xml"
  export = SpanReport::Process::Export.new

  logfiles = SpanReport.list_files(log_path, ["lgl"])

  File.foreach("config/export.ini") do |line|
    line.chop!
    contents = line.split ':'
    export.reg_iename contents[0], contents[1]
  end

  config_map = {}
  File.foreach("config/config.ini") do |line|
    line.chop!
    contents = line.split ':'
    config_map[contents[0]] = contents[1] unless contents[0].empty?
  end

  #多个日志合并导出
  if config_map["combine"] == "true"
    begin
      filereader = SpanReport::Logfile::FileReader.new logfiles
      filereader.parse(export)
      resultfile = "log/combine.csv"
      export.write_result(resultfile)
      export.clear
    rescue Exception => e
      puts e
    ensure
      filereader.clear_files
    end
  #日志分别导出
  else
    logfiles.each do |logfile|
      begin
        filereader = SpanReport::Logfile::FileReader.new [logfile]
        filereader.parse(export)
        resultfile = logfile.sub('lgl', 'csv')
        export.write_result(resultfile)
        export.clear
      rescue Exception => e
        puts e.message
      ensure
        filereader.clear_files
      end
    end
  end
end

export "./log"