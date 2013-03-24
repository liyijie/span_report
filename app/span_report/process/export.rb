# encoding: utf-8


module SpanReport::Process
  
  class Export < Base

    def initialize
      super
      @export_datas = []
      @file = nil
    end

    def process_data logdata, file_group=""
      contents = logdata.split(/,|:/)
      group_id = contents[1].to_i
      needed_ies = get_needed_ies group_id

      last_data = @export_datas[-1]
      last_data ||= []
      export_data = []
      is_lastdata = false
      #如果是和上一条一样时间的数据，如果值不为空，则进行覆盖
      if contents[2] == last_data[1] && contents[0] == last_data[2]
        export_data = last_data
        is_lastdata = true
      #如果是和上一条不一样的时间，如果值不为空，则创建一条，加入到队列中
      else
        export_data = []
        #time
        export_data[0] = convert_time contents[2]
        #pctime
        export_data[1] = contents[2]
        #ueid
        export_data[2] = contents[0]
      end

      needed_ies.each do |logitem|
        ie_index = logitem.index + 3
        ie_name = logitem.name
        data_index = get_data_index ie_name

        if data_index && contents[ie_index] && !contents[ie_index].empty?
          export_data[data_index] = contents[ie_index]
        end
      end

      if export_data.size > 3 && !is_lastdata
        @export_datas << export_data 
        write_result
      end
    end

    def get_data_index iename
      index = @reg_ies.index iename
      # time, pctime, ueid, ie1, ie2
      index += 3 if index
      index
    end

    def config_export_file result_file
      puts "export file is:#{result_file}"
      @file = File.new(result_file, "w")
      @file.puts head_string
    end

    def head_string
      head = "Time,PCTime,UEid"
      @reg_ies.each do |iename|
        head << ",#{@alis_map[iename]}"
      end
      head
    end

    def write_result   
      if @export_datas.size > 100
        flush
      end
    end

    def flush
      @export_datas.each do |datas|
        data_string = ""
        datas.each_with_index do |data, index|
          data ||= ""
          data_string << data
          data_string << "," if index != datas.length-1
        end
        @file.puts data_string
      end
      @export_datas.clear
    end

    def clear
      @export_datas = []
    end

  end
end