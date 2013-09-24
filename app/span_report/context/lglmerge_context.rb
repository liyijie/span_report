# encoding: utf-8

require 'fileutils'  
require 'zip/zip'  
require 'zip/zipfilesystem' 


module SpanReport::Context
  class LglmergeContext < BaseContext

    def initialize path
      super
      @filetime_array = []
    end


    # 合并日志文件，把一个文件夹下面的日志都合并到一个目录中
    # 1. 对于IE详细的文件，直接解压缩以后，等待最后的合并即可
    # 2. 对于事件、信令、map数据，需要合并后，按照时间进行排序后再进行合并
    # 3. 压缩文件夹
    def process
      
      dest_dir = File.join @output_log, "temp"

      # 解压缩
      logfiles = SpanReport.list_files(@input_log, ["lgl"])
      logfiles.each_with_index do |logfile, file_index|
        zip_file = logfile.filename
        unzip zip_file, dest_dir, file_index
      end

      # 排序
      @filetime_array = @filetime_array.sort_by do |filetime_info|
        filetime_info.file_time
      end

      # 合并相关的文件
      ["signal", "event", "map.csv", "IndoorPointmap"].each do |file_type|
        merge file_type, dest_dir
      end

      # 压缩
      zipfile = File.join @output_log, "merge.lgl"
      zip dest_dir, zipfile

      # 删除
      FileUtils.rm_rf dest_dir
    end

    private

    def zip source_path, zipfile
      FileUtils.rm zipfile if File.exist? zipfile
      Zip::ZipFile.open(zipfile,Zip::ZipFile::CREATE) do |zipfile|
        # 给压缩文件中添加文件
        # 第一个参数 被添加文件在压缩文件中显示的路径
        # 第二个参数 被添加文件的源路径
        SpanReport.list_files(source_path, ["txt"]).each do |iefile|
          file_name = iefile.filename.split(/\\|\//)[-1]
          file_name = file_name.sub ".txt", ""
          source_file = iefile.filename
          zipfile.add file_name, source_file
        end
       
      end
    end

    #解压文件到临时目录中，为每个日志都解压到当前的文件夹中
    #返回解压后的目录
    def unzip zip_file, dest_dir, file_index
      puts "unzip log #{zip_file}"
      zipfile_name = zip_file.split(/\\|\//)[-1]
      puts "zipfile_name is:#{zipfile_name}"
      Dir.mkdir(dest_dir) unless File.exist?(dest_dir)
      start_time = 9999999999999999


      Zip::ZipFile.open zip_file do |zf|
        zf.each do |e|
          filename = e.name
          unless ["signal", "event", "map.csv", "IndoorPointmap"].index filename
            path = File.join dest_dir,"#{e.name}.txt" 
            temp_time = e.name.split('_')[0].to_s.to_i
            if temp_time < start_time && temp_time > 0
              start_time = temp_time
            end
          else
            path = File.join dest_dir,"#{file_index}.#{e.name}" 
          end
          zf.extract(e, path) { true } 
        end  
      end
      @filetime_array << FileTimeInfo.new(file_index, start_time)
      dest_dir
    end

    def merge file_type, dest_dir
      dest_file = File.join dest_dir, "#{file_type}.txt"
      has_head = false
      File.open(dest_file, "w") do |file|
        @filetime_array.each do |filetime_info|
          file_index = filetime_info.file_index
          begin
            filename = "#{file_index}.#{file_type}"
            filename = File.join dest_dir, filename
            line_index = 0
            File.foreach(filename) do |line|
              line_index += 1
              line = line.chop
              if has_head && line_index == 1
                next
              end
              file.puts line
            end
            has_head = true
          rescue Exception => e
            next
          end
        end  
      end
    end

  end

  class FileTimeInfo
    attr_accessor :file_index, :file_time

    def initialize file_index, file_time
      @file_index, @file_time = file_index, file_time
    end

    def to_s
      "file_index is:#{file_index}, file_time is:#{file_time}"
    end
  end
end