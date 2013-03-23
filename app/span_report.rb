# encoding: utf-8

require 'logger'

$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), "..", "app"))

require "nokogiri"

module SpanReport

  autoload :Condition, "span_report/condition"
  autoload :Model, "span_report/model"
  autoload :Logfile, "span_report/logfile"
  autoload :Process, "span_report/process"
  autoload :Context, "span_report/context"
  autoload :Simulate, "span_report/simulate"
  autoload :Lglconvert, "span_report/lglconvert"

  file = open('log.txt', File::WRONLY | File::CREAT | File::TRUNC)  
  @@logger = Logger.new(file)

  def self.logger
    @@logger
  end

  #递归遍历文件夹下指定类型的文件,只会遍历一层文件夹
  def self.list_files(file_path, file_types)
    files = []

    Dir.foreach file_path do |file|
      next if file == "." or file == ".."
      next if file == "signal" or file == "event" or file == "map.csv"
      file = file.encode 'utf-8'
      file_path = file_path.encode 'utf-8'

      #文件夹，展开，里面的日志是分组日志
      filename = "#{file_path}/#{file}"
      if File.directory? filename
        group = file
        Dir.foreach(filename) do |logfile|
          next if logfile == "." or logfile == ".."
          logfile = logfile.encode 'utf-8'
          file_types.each do |file_type|
            if logfile=~/.#{file_type}$/
              fileinfo = FileInfo.new "#{filename}/#{logfile}", group
              files << fileinfo
            end
          end
        end
      else
        file_types.each do |file_type|
          if filename=~/.#{file_type}$/
            fileinfo = FileInfo.new filename, ""
            files << fileinfo
          end
        end
      end
    end
    files.each do |fileinfo|
      SpanReport.logger.debug fileinfo
    end
    files
  end


  class FileInfo

    attr_accessor :filename, :filegroup
    def initialize filename, filegroup
      @filename = filename.encode "utf-8"
      @filegroup = filegroup.encode "utf-8"
    end

    def to_s
      "filename is:#{filename}, filegroup is:#{filegroup}"
    end
  end

end
