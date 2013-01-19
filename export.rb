# encoding: utf-8

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


def export(log_path)
  SpanReport::Model::Logformat.instance.load_xml "config/LogFormat_100.xml"
  export = SpanReport::Process::Export.new

  logfiles = list_files(log_path, ["lgl"])

  File.foreach("config/export.ini") do |line|
    line.chop!
    contents = line.split ':'
    export.reg_iename contents[0], contents[1]
  end

  logfiles.each do |logfile|
    begin
      filereader = SpanReport::Logfile::FileReader.new(logfile)
      filereader.parse(export)
      resultfile = logfile.sub('lgl', 'csv')
      export.write_result(resultfile)
    rescue Exception => e

    ensure
      filereader.clear_files
    end
  end
end

export "./log"