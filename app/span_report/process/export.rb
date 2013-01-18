# encoding: utf-8


module SpanReport::Process
  
  class Export

    def initialize
      @reg_ies = []
      @reg_groups = {}
      @alis_map = {}
      @export_datas = []
    end

    def reg_iename iename, alisname
      @reg_ies << iename
      @alis_map[iename] = alisname
      logitem = SpanReport::Model::Logformat.instance.get_logitem(iename)
      if logitem
        @reg_groups[logitem.group] ||= []
        @reg_groups[logitem.group] << logitem
      end
    end

    def add_logdata logdata
      process_data logdata if data_needed? logdata
    end

    def data_needed? logdata
      group_id = logdata.split(',', 3)[1].to_i
      @reg_groups.has_key? group_id
    end

    def process_data logdata
      contents = logdata.split(/,|:/)
      group_id = contents[1].to_i
      needed_ies = @reg_groups[group_id]

      #last data
      last_data = @export_datas[-1]
      last_data ||= []
      is_lastdata = false
      if contents[2] == last_data[1] && contents[0] == last_data[2] 
        export_data = last_data
        is_lastdata = true
      else
        export_data = []
        #time
        export_data[0] = convert_time contents[2]
        #pctime
        export_data[1] = contents[2]
        #ueid
        export_data[2] = contents[0]
      end

      #ievalues
      is_value = false
      needed_ies.each do |logitem|
        ie_index = logitem.index + 3
        ie_name = logitem.name
        data_index = get_data_index ie_name

        export_data[data_index] = contents[ie_index] if data_index
        is_value = true if data_index && !contents[ie_index].empty? && !is_lastdata
      end

      @export_datas << export_data if is_value
    end

    def get_data_index iename
      index = @reg_ies.index iename
      # time, pctime, ueid, ie1, ie2
      index += 3 if index
      index
    end

    def convert_time pctime
      time = Time.new(2000,1,1) + pctime.to_f/1000
      dis_time = "#{time.hour}:#{time.min}:#{format("%.3f", time.sec+time.subsec)}"
    end

    def write_result result_file
      File.open(result_file, "w") do |file|
        head = "Time,PCTime,UEid"
        @reg_ies.each do |iename|
          head << ",#{@alis_map[iename]}"
        end
        file.puts head

        @export_datas.each do |datas|
          data_string = ""
          datas.each_with_index do |data, index|
            data ||= ""
            data_string << data
            data_string << "," if index != datas.length-1
          end
          file.puts data_string
        end
      end
    end

  end
end