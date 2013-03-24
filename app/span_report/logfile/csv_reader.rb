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

        parse_one_file filename,processors
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

  end

end