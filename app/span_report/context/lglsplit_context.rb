# encoding: utf-8

require 'fileutils'  
require 'zip/zip'  
require 'zip/zipfilesystem' 


module SpanReport::Context
  class LglsplitContext < BaseContext

    def initialize path
      super
    end

    def load_relate
      doc = Nokogiri::XML(open(CONFIG_FILE))
      doc.search(@function).each do |relate|
        @timeinfos = []
        relate.search("time").each do |time_info|
          timeinfo = TimeInfo.new
          timeinfo.start_time = time_info.get_attribute("start").to_i
          timeinfo.end_time = time_info.get_attribute("end").to_i
          @timeinfos << timeinfo
        end
        puts @timeinfos
      end
    end

    # 1. 把文件解压到临时文件夹中，对于临时文件加上txt的后缀，对于其他类型的文件，加上list的后缀
    # 2. 对于txt后缀的IE块文件，进行切分，结果文件放置到临时文件夹中，后缀为txt
    # 3. 对于其他list后缀的信令事件等文件，进行切分，结果文件放置到临时结果文件夹中，后缀为list
    # 4. 把临时结果文件夹的数据进行打包，把rlt的后缀去除

    def process

      unzip_temp_dir = File.join @output_log, "temp"

      FileUtils.rm_rf unzip_temp_dir if File.exist?(unzip_temp_dir)
      Dir.mkdir(unzip_temp_dir)

      # 1. 解压缩
      logfiles = SpanReport.list_files(@input_log, ["lgl"])
      logfiles.each_with_index do |logfile, file_index|
        zip_file = logfile.filename
        unzip zip_file, unzip_temp_dir
      end

      @timeinfos.each do |timeinfo|
        result_dir = File.join @output_log, "#{timeinfo}"
        FileUtils.rm_rf result_dir if File.exist?(result_dir)
        Dir.mkdir(result_dir)

        # 2. 切分文件
        # 块文件
        # 如果文件开始和结束时间都在切分范围内的直接进行拷贝
        blockfiles = SpanReport.list_files(unzip_temp_dir, ["txt"])
        blockfiles.each do |blockfile|
          blockfile_name = blockfile.filename.split(/\\|\//)[-1]
          time_contents = blockfile_name.split('_')
          start_time = time_contents[0].to_s.to_i
          end_time = time_contents[1].to_s.to_i
          if (timeinfo.in?(start_time) && timeinfo.in?(end_time))
            FileUtils.copy_file blockfile.filename, (File.join(result_dir, blockfile_name))
          elsif timeinfo.in?(start_time)
            dest_filename = "#{start_time}_#{timeinfo.end_time}.txt"
            dest_file = File.join result_dir, dest_filename
            split_blockfile blockfile.filename, dest_file, timeinfo
          elsif timeinfo.in?(end_time)
            dest_filename = "#{timeinfo.start_time}_#{end_time}.txt"
            dest_file = File.join result_dir, dest_filename
            split_blockfile blockfile.filename, dest_file, timeinfo
          end
        end

        # list文件，直接进行分割
        list_files = SpanReport.list_files(unzip_temp_dir, ["list"])
        list_files.each do |listfile|
          listfile_name = listfile.filename.split(/\\|\//)[-1]
          dest_file = File.join result_dir, "#{listfile_name.sub(".list", ".txt")}"
          split_listfile listfile.filename, dest_file, timeinfo
        end

        # 压缩
        zipfile = File.join @output_log, "#{timeinfo}.lgl"
        zip result_dir, zipfile

        # 删除
        FileUtils.rm_rf result_dir
      end

      # 删除
      FileUtils.rm_rf unzip_temp_dir

    end

    private

    def split_blockfile src_file, dest_file, timeinfo
      File.open(dest_file, "w") do |file|
        File.foreach(src_file) do |line|
          line = line.chop
          contents = line.split(/,|:/)
          time = contents[2]
          file.puts line if timeinfo.in? time
        end
      end
    end

    def split_listfile src_file, dest_file, timeinfo
      File.open(dest_file, "w") do |file|
        line_index = 0
        File.foreach(src_file) do |line|
          line_index += 1
          line = line.chop
          if line_index == 1
            file.puts line
          else
            contents = line.split(/,|:/)
            time = contents[1]
            file.puts line if timeinfo.in? time
          end 
        end
      end
    end

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
    def unzip zip_file, dest_dir
      Dir.mkdir(dest_dir) unless File.exist?(dest_dir)

      Zip::ZipFile.open zip_file do |zf|
        zf.each do |e|
          filename = e.name
          unless ["signal", "event", "map.csv", "IndoorPointmap"].index filename
            path = File.join dest_dir,"#{e.name}.txt" 
          else
            path = File.join dest_dir,"#{e.name}.list" 
          end
          zf.extract(e, path) { true } 
        end  
      end
      dest_dir
    end

  end

  class TimeInfo
    attr_accessor :start_time, :end_time

    def in? time
      ltime = time.to_i
      ltime >= @start_time && ltime <= @end_time
    end

    def to_s
      "#{start_time}_#{end_time}"
    end
  end
end