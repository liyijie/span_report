# encoding: utf-8

module SpanReport::Logfile

  class CsvReader
    ###################################################
    # 这里传入的files并不是普通的文件名，而是封装的结构
    ##################################################
    def initialize(files)
      @files = files
    end

    def parse(processors)
      @files.each do |fileinfo|
        filename = fileinfo.filename
        puts "process log #{filename}"

        # parse_one_file filename,processors
        parse_temp_file filename, processors
      end
    end

    def parse_one_file filename, processors
      line_index = 0
      head_info = []
      File.foreach(filename) do |line|
        contents = line.split ','
        if line_index == 0
          contents.each do |item| 
            head_info << item
          end
        else
          data_map = {}
          contents.each_with_index do |item, i|
            data_map[head_info[i].to_s] = item
          end
          # 调用每个处理器处理数据
          processors.each do |process|
            # begin
              process.process_csv_data data_map
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

        # 调用每个处理器处理数据
        processors.each do |process|
          # begin
            process.process_csv_data data_map
          # rescue Exception => e
          #   puts "process data error:#{e.backtrace}"
          #   next
          # end
        end

        line_index += 1
      end
    end
  end

end