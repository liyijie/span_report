# encoding: utf-8


module SpanReport::Process
  
  class Export < Base

    def initialize
      super
      @export_datas = []
      @data_counts = 0
      @file = nil
    end

    ############################################
    #判断数据是否需要进行处理
    ############################################
    def data_needed? logdata
      contents = logdata.split(/,|:/)
      group_id = contents[1].to_i
      pctime = contents[2].to_i
      is_needed = @reg_groups.has_key?(group_id) && time_valid?(pctime) && data_counts_valid?
      is_needed
    end

    def add_range range_context
      @count_range = range_context[:count_range].to_i
      @begin_time = range_context[:begin_time]
      @end_time = range_context[:end_time]
    end

    def time_valid? pctime
      return true if @begin_time.to_s.empty? && @end_time.to_s.empty?

      pc_time = Time.at_pctime pctime
      pc_stime = pc_time.hour * 3600 + pc_time.min * 60 + pc_time.sec

      array = @begin_time.split(":")
      begin_stime = array[0].to_i * 3600 + array[1].to_i * 60 + array[2].to_i
      array = @end_time.split(":")
      end_stime = array[0].to_i * 3600 + array[1].to_i * 60 + array[2].to_i
      # puts "pctime is:#{pc_stime}, begintime is:#{begin_stime}, endtime is:#{end_stime}"

      result = end_stime > begin_stime && pc_stime > begin_stime && end_stime > pc_stime
      result
    end

    def data_counts_valid?
      @count_range == 0 || (@count_range > 0 && @data_counts < @count_range)
    end

    def process_data logdata, file_group=""
      contents = logdata.split(/,|:/)
      group_id = contents[1].to_i
      needed_ies = get_needed_ies group_id

      @last_data ||= {}
      ue_id = contents[0].to_i
      pctime = contents[2].to_i
      

      @last_data[ue_id] ||= {}
      @last_data[ue_id]["PCTime"] ||= pctime
      @last_data[ue_id]["UEid"] ||= ue_id
      @last_data[ue_id]["Time"] ||= convert_time(pctime)
      # if the time is in 1s, then cover the data
      # else push the data to export_datas, then empty the relate ue's last_data
      delta_time = pctime - @last_data[ue_id]["PCTime"]

      if delta_time >= 1000
        export_data = @last_data[ue_id].clone
        
        @export_datas << export_data
        @data_counts += 1
        @last_data[ue_id] = {}
        @last_data[ue_id]["PCTime"] ||= pctime
        @last_data[ue_id]["UEid"] ||= ue_id
        @last_data[ue_id]["Time"] ||= convert_time(pctime)
      end

      needed_ies.each do |logitem|
        ie_index = logitem.index + 3
        ie_name = logitem.name
        unless contents[ie_index].to_s.empty?
          @last_data[ue_id][ie_name] = contents[ie_index] if contents[ie_index].to_s != "-999"
        end 
      end

      if export_data.size > 3 && !is_lastdata
        @export_datas << export_data
        @data_counts += 1 
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
      self.head.join ","
    end

    def head
      if @head.nil?
        @head = ["Time", "PCTime", "UEid"]
        @reg_ies.each do |iename|
          @head << iename
        end
      end
      @head
    end

    def write_result   
      if @export_datas.size > 100
        flush
      end
    end

    def flush
      @export_datas.each do |datas|
        data_string = self.head.map { |key| datas[key] }.join(",")
        @file.puts data_string
      end
      @export_datas.clear
    end

    def close_file
      flush
      @file.close if @file
    end

    def clear
      @export_datas = []
    end

  end
end