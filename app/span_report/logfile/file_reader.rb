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
    
    def initialize(files)
      @files = files
      @unzip_paths = []
    end

    def parse(processor)
      @files.each do |fileinfo|
        filename = fileinfo.filename
        puts "process log #{filename} "
        
        filepath = unzip filename, "./config"
        # file_group = get_file_group filename
        file_group = fileinfo.filegroup
        logs = list_files(filepath, ["txt"])
        logs.each do |logfile|
          begin
            process(logfile, processor, file_group)
          rescue Exception => e
            next
          end
        end
        puts ""
      end
    end

    def process(logfile, processor, file_group)
      # puts "process #{logfile}, file_group is:#{file_group} ......"
      putc "."
      File.foreach(logfile) do |line|
        processor.add_logdata line, file_group
      end
    end

    #解压文件到临时目录中，为每个日志都解压到当前的文件夹中
    #返回解压后的目录
    def unzip zip_file, dest_dir
      puts "unzip log #{zip_file}"
      zipfile_name = File.split(zip_file)[-1]
      unzip_dir = File.join dest_dir, zipfile_name
      Dir.mkdir(dest_dir) unless File.exist?(dest_dir)
      Dir.mkdir(unzip_dir) unless File.exist?(unzip_dir)
      @unzip_paths << unzip_dir

      Zip::ZipFile.open zip_file do |zf|  
        zf.each do |e|
          path = File.join unzip_dir, "#{e.name}.txt"  
          zf.extract(e, path) { true }  
        end  
      end
      unzip_dir
    end 

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

    def clear_files
      @unzip_paths.each do |unzip_path|
        FileUtils.rm_rf unzip_path
      end
    end

    ##这里传入的file是带路径的
    def get_file_group file
      filename = File.split(file)[-1]
      contents = filename.split '.'
      file_group = ""
      if contents.size > 2
        file_group = contents[-2]
      end
      file_group
    end

  end
  
end