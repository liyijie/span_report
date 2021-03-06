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
    
    ###################################################
    # 这里传入的files并不是普通的文件名，而是封装的结构
    ##################################################
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

        list_logs = list_files(filepath, ["list"])
        list_logs.each do |logfile|
          begin
            process_list(logfile, processor, file_group)
          rescue Exception => e
            puts "#{__FILE__}(#{__LINE__}):#{e}"
          end
        end

        logs = list_files(filepath, ["txt"])
        logs.each do |logfile|
          # begin
            process(logfile, processor, file_group)
          # rescue Exception => e
            # puts "#{__FILE__}(#{__LINE__}):#{e}"
          # end
        end
        puts ""
      end
    end

    def parse_many(processors)
      @files.each do |fileinfo|
        filename = fileinfo.filename
        puts "process log #{filename} "
        
        filepath = unzip filename, "./config"
        # file_group = get_file_group filename
        file_group = fileinfo.filegroup

        list_logs = list_files(filepath, ["list"])
        list_logs.each do |logfile|
          processors.each do |processor|
            begin
              process_list(logfile, processor, file_group)
            rescue Exception => e
              puts "#{__FILE__}(#{__LINE__}):#{e}"
              next
            end
          end
        end

        logs = list_files(filepath, ["txt"])
        logs.each do |logfile|
          processors.each do |processor|
            begin
              process(logfile, processor, file_group)
            rescue Exception => e
              puts "#{__FILE__}(#{__LINE__}):#{e}"
              next
            end
          end
        end

        puts ""
      end
    end

    def process(logfile, processor, file_group)
      # puts "process #{logfile}, file_group is:#{file_group} ......"
      putc "."
      processor.before_process(logfile, file_group)if processor.respond_to? :before_process
      File.foreach(logfile) do |line|
        begin
          processor.add_logdata line, file_group
        rescue Exception => e
          next
        end
      end
      processor.before_process if processor.respond_to? :after_process
    end

    def process_list(logfile, processor, file_group="")
      if logfile == "event.list" && processor.respond_to?(:add_event)
        processor.clear_event
        index = 0
        File.foreach(logfile) do |line|
          index += 1
          processor.add_event line, file_group unless index == 1
        end
      elsif logfile == "signal.list" && processor.respond_to?(:add_signal)
        processor.clear_signal
        index = 0
        File.foreach(logfile) do |line|
          index += 1
          processor.add_signal line, file_group unless index == 1
        end
      end
    end

    #解压文件到临时目录中，为每个日志都解压到当前的文件夹中
    #返回解压后的目录
    def unzip zip_file, dest_dir
      puts "unzip log #{zip_file}"
      zipfile_name = zip_file.split(/\\|\//)[-1]
      puts "zipfile_name is:#{zipfile_name}"
      # File.split(zip_file)[-1]
      unzip_dir = File.join dest_dir, zipfile_name
      Dir.mkdir(dest_dir) unless File.exist?(dest_dir)
      Dir.mkdir(unzip_dir) unless File.exist?(unzip_dir)
      @unzip_paths << unzip_dir

      Zip::ZipFile.open zip_file do |zf|
        zf.each do |e|
          if ["signal", "event", "map.csv", "IndoorPointmap"].index e.name
            path = File.join unzip_dir,"#{e.name}.list"
          else 
            path = File.join unzip_dir,"#{e.name}.txt"
          end
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