# encoding: utf-8

require 'fileutils'  
require 'zip/zip'  
require 'zip/zipfilesystem' 

module SpanReport::Logfile

  # read the lgl file
  # 1. unzip the lgl file
  # 2. read the log file perline
  # 3. call back the process with perline data
  class FileReader
    
    def initialize(filename)
      @filename = filename
    end

    def parse(processor)
      unzip @filename, "config/temp"

    end


    #解压文件到临时目录中，为每个日志都解压到当前的文件夹中
    def unzip zip_file, dest_dir
      zipfile_name = File.split(zip_file)[1]
      unzip_dir = File.join dest_dir, zipfile_name
      Dir.mkdir(dest_dir) unless File.exist?(dest_dir)
      Dir.mkdir(unzip_dir) unless File.exist?(unzip_dir)

      Zip::ZipFile.open zip_file do |zf|  
        zf.each do |e|
          path = File.join unzip_dir, e.name  
          zf.extract(e, path) { true }  
        end  
      end  
    end  
  end
  
end