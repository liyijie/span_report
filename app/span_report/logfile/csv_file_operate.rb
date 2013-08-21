# encoding: utf-8

module SpanReport::Logfile

  class CsvReader
    ###################################################
    # 这里传入的files并不是普通的文件名，而是封装的结构
    ##################################################
    def initialize(files, is_temp=false)
      @files = files
      @is_temp = is_temp
    end

    def parse(processors)
      @files.each do |fileinfo|
        filename = fileinfo.filename
        puts "process log #{filename}"
        if @is_temp
          parse_temp_file filename, processors
        else
          parse_one_file filename,processors
        end
      end
    end

    private

    def parse_one_file filename, processors
      line_index = 0
      head_info = []
      File.foreach(filename) do |line|
        line = line.chop
        contents = line.split ','
        if line_index == 0
          contents.each do |item| 
            head_info << item
          end
        else
          data_map = {}
          contents.each_with_index do |item, i|
            next if item.to_s.empty?
            data_map[head_info[i].to_s] = item
          end
          time = data_map["time"]
          ue = data_map["ue"]
          data_map.map do |key, value|
            key = key.encode('utf-8')
            value = value.encode('utf-8')
          end
          point_data = SpanReport::Simulate::PointData.new time, ue, data_map
          point_data.expand_data
          
          next if (point_data.rsrp.to_f <= -140) || !point_data.valid?
      
          # 调用每个处理器处理数据
          processors.each do |process|
            # begin
              process.process_pointdata point_data
            # rescue Exception => e
            #   puts "process data error:#{e.backtrace}"
            #   next
            # end
          end
        end
        line_index += 1
      end
    end

    def parse_temp_file filename, processors
      line_index = 0
      File.foreach(filename) do |line|
        if line_index == 0
          line_index += 1
          next
        end
        line = line.chop
        contents = line.split ','
        data_map = {}
        data_map["time"] = contents[0]
        data_map["ue"] = "1"
        data_map["lontitute"] = contents[3]
        data_map["latitude"] = contents[4]
        data_map["scell_pci"] = contents[5]
        data_map["scell_freq"] = "1890"
        data_map["scell_rsrp"] = contents[6]
        data_map["scell_sinr"] = 0

        (0..7).each do |i|
          data_map["ncell_pci_#{i}"] = contents[7 + 2*i]
          data_map["ncell_freq_#{i}"] = "1890"
          data_map["ncell_rsrp_#{i}"] = contents[8 + 2*i]
        end
        time = data_map["time"]
        ue = data_map["ue"]
        point_data = SpanReport::Simulate::PointData.new time, ue, data_map
        point_data.expand_data

        # 调用每个处理器处理数据
        processors.each do |process|
          # begin
            process.process_pointdata point_data
          # rescue Exception => e
          #   puts "process data error:#{e.backtrace}"
          #   next
          # end
        end

        line_index += 1
      end
    end
  end

  class CsvWriter

    def initialize resultfile
      @export_datas = []
      open_file resultfile
    end

    def add_data pointdata
      @export_datas << pointdata
      write_result
    end

    def << pointdata
      add_data pointdata
    end

    def close_file
      flush
      @file.close if @file
    end

    private

    def open_file result_file
      # puts "output csv file is:#{result_file}"
      result_file = result_file.encode 'gbk'
      @file = File.new(result_file, "w")
      @file.puts head_string
    end

    def write_result
      if @export_datas.size > 100
        flush
      end
    end

    def flush
      @export_datas.each do |pointdata|
        @file.puts pointdata.to_s.encode 'gbk'
      end
      @export_datas.clear
    end

    def head_string
      SpanReport::Simulate::PointData.head_string
    end
  end

end