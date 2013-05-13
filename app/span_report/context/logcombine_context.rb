# encoding: utf-8

require 'fileutils'  
require 'zip/zip'  
require 'zip/zipfilesystem' 


module SpanReport::Context
  class LogcombineContext < BaseContext

    def initialize path
      super
    end


    # 合并日志文件，把一个文件夹下面的日志都合并到一个目录中
    # 1. 对于IE详细的文件，直接解压缩以后，等待最后的合并即可
    # 2. 对于事件、信令、map数据，需要合并后，按照时间进行排序后再进行合并
    # 3. 压缩文件夹
    def process
      
      cell_list = []
      celllist_filename = File.join @input_log, "celllist.txt"

      File.foreach(celllist_filename) do |line|
        line = line.chop
        cell_list << line
      end   
      merge cell_list, "#{@input_log}/map"
    end

    private

    

    def merge cell_list, dest_dir
      dest_file = File.join @output_log, "relate_combine.csv"
      has_head = false
      File.open(dest_file, "w") do |file|
        cell_list.each do |cell_name|
          begin
            filename = "#{cell_name}.csv"
            filename = File.join dest_dir, filename
            line_index = 0
            File.foreach(filename) do |line|
              line_index += 1
              line = line.chop
              if has_head && line_index == 1
                next
              end
              file.puts "#{line},#{cell_name.encode('gbk')}"
            end
            has_head = true
          rescue Exception => e
            next
          end
        end  
      end
    end

  end

end