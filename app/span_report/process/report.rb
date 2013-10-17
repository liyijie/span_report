# encoding: utf-8

module SpanReport::Process

  class Report < Base

    attr_accessor :kpi_caches
    ########################################
    #缓存中保存的key都是长IE的名称，方便进行访问
    #通过log组号和IE所在的相关位置
    #
    #
    #
    #
    ########################################
    def initialize
      super
      @counter_item_map = {} #key is iename, value ie counter_item list
      @ie_caches = {}
      @kpi_caches = {}
      @kpi_items = []
    end

    ########################################
    #处理日志中的一条数据
    #这里已经通过校验，已经是包含需要处理的数据
    #1. 把日志数据中相关的IE都能加入到IE缓存中
    #2. 如果是counter相关的数据，则计算相关的counter值
    #
    #########################################
    def process_data logdata, file_group=""
      contents = logdata.split(/,|:/)
      group_id = contents[1].to_i
      pctime = contents[2].to_i
      needed_ies = get_needed_ies group_id

      needed_ies.each do |logitem|
        ie_name = logitem.name
        ie_index = logitem.index + 3
        @ie_caches[ie_name] = contents[ie_index] unless contents[ie_index].to_s.empty?

        ie_value = contents[ie_index]
        report_caculate ie_name, ie_value, pctime, file_group
      end
    end

    def process_ies ie_map, pctime, file_group=""
      ie_map.each do |ie_name, ie_value|
        ie_name = ie_name.to_s
        next if ie_value.to_s.empty?
        @ie_caches[ie_name] = ie_value
        report_caculate ie_name, ie_value, pctime, file_group
      end
    end

    # 处理器，增加IE触发器的结构
    # 通过邻区结构生成重叠覆盖度这个IE
    def before_process logdata, file_group=""
      contents = logdata.split(/,|:/)
      group_id = contents[1].to_i
      pctime = contents[2].to_i
      over_range_count = 1
      if group_id == 1195
        rsrp_array = []
        s_rsrp = @ie_caches["TDDLTE_L1_measurement_Serving_Cell_Measurement_RSRP"].to_f
        rsrp_array << s_rsrp if s_rsrp < 0

        (0..7).each do |index|
          n_rsrp = contents[3+index].to_f
          rsrp_array << n_rsrp if n_rsrp < 0
        end

        if rsrp_array.size > 1
          sort_array = rsrp_array.sort_by do |rsrp|
            rsrp.to_f * -1
          end

          s_rsrp = sort_array[0]
          (1..sort_array.size-1).each do |index|
            n_rsrp = sort_array[index]
            over_range_count += 1 if (s_rsrp >= -105 && s_rsrp < 0 && n_rsrp < 0 && (n_rsrp - s_rsrp) > -6) 
          end
        end

        @ie_caches["over_range_count"] = over_range_count
        report_caculate "over_range_count", over_range_count, pctime, file_group
      end
    end


    def clear_event
      @event_map.clear
    end

    def clear_signal
      @signal_map.clear
    end

    def add_event logdata
      contents = logdata.split(",")
      pctime = contents[1].to_i
      event = contents[6].to_s
      @event_map[event] ||= []
      @event_map[event] << pctime
    end

    def add_signal logdata
      contents = logdata.split(",")
      pctime = contents[1].to_i
      signal = contents[6].to_s
      @signal_map[signal] ||= []
      @signal_map[signal] << pctime
    end

    def add_counter_cache counter_name, counter_ievalue, count_mode, pctime=0, is_valid=true
      unless @kpi_caches.has_key? counter_name
        @kpi_caches[counter_name] = SpanReport::Process::Value.create count_mode
      end

      # 获取GPS信息
      lat = @ie_caches["dbLat"].to_f
      lon = @ie_caches["dbLon"].to_f
      if (lat > 0 && lat < 90 && lon > 0 && lon < 180)
        gps = Point.new(lat, lon)
      else
        gps = nil
      end
      
      report_value = @kpi_caches[counter_name]
      #需要校验这条数据是否能满足counter item定义的条件
      if is_valid
        report_value.add_value counter_ievalue, pctime, gps
      else
        report_value.add_invalid_value counter_ievalue, pctime, gps
      end
    end

    def reg_counter_item counter_item
      iename = counter_item.iename
      #由于对于同一个ie可能会同时定义counter，因此这里使用数组
      @counter_item_map[iename] ||= []
      @counter_item_map[iename] << counter_item
      reg_iename iename, iename

      # 注册相关联条件的IE
      relate_conditions = counter_item.relate_conditions
      relate_conditions.each do |condition|
        condition_iename = condition.iename
        reg_iename condition_iename, condition_iename
      end
    end

    def reg_kpi_item kpi_item
      @kpi_items << kpi_item
    end

    ########################################
    #根据报表模板中的KPI获取相关的值
    #这里需要注意的是，这里的名称是可以进行扩展的
    #基本的格式如下：
    #1. kpiname
    #2. loggroup#kpiname
    #3. kpiname[1]
    #4. kpiname[0][1]
    #5. kpiname_1[0][1]
    #6. kpiname(param1,params2)
    #########################################
    def get_kpi_value(kpi_name)
      if (kpi_name =~ /\(/)
        params = kpi_name.split(/\(|\)|,/)
        real_name = params.delete_at(0)
        # puts "real_name is:#{real_name}, params is:#{params.inspect}"
        reportvalue = @kpi_caches[real_name]
        if reportvalue
          value = reportvalue.getvalue params
        end
      else
        reportvalue = @kpi_caches[kpi_name]
        if reportvalue
          value = reportvalue.getvalue
        end
      end
      value ||= ""
        SpanReport.logger.debug "the kpi is:#{kpi_name}, value is:#{value}, reportvalue is:#{reportvalue}"
      value
    end

    def has_kpi_value?(kpi_name)
      @kpi_caches.has_key? kpi_name
    end

    def count_kpi_value
      @kpi_items.each do |kpi_item|
        kpi_item.eval_value! @kpi_caches
      end
    end

    def clear
      @ie_caches = {}
      @kpi_caches = {}
    end

    private

    def report_caculate ie_name, ie_value, pctime, file_group=""
      ie_name = ie_name.to_s
      if @counter_item_map.has_key? ie_name
        counter_items = @counter_item_map[ie_name]
        counter_items.each do |counter_item|

          counter_name = counter_item.name
          counter_ievalue = ie_value
          count_mode = counter_item.count_mode
          is_valid = counter_item.validate? @ie_caches
          #对不带file_group进行全局统计
          add_counter_cache counter_name, counter_ievalue, count_mode, pctime, is_valid

          #如果file_group不为空，则需要再对file_group进行统计
          unless file_group.to_s.empty?
            group_counter_name = "#{file_group}##{counter_name}"
            add_counter_cache group_counter_name, counter_ievalue, count_mode, pctime, is_valid
          end
        end
      end
    end
  end

  class Point
    attr_reader :lat, :lon

    def initialize(lat, lon)
      @lat = lat.to_f
      @lon = lon.to_f
    end

    def distance point
      begin
        lng1 = @lon
        lat1 = @lat
        lng2 = point.lon
        lat2 = point.lat
        rad = Math::PI / 180.0
        earth_radius = 6378.137 * 1000 #地球半径
        radLat1 = lat1 * rad
        radLat2 = lat2 * rad
        a = radLat1 - radLat2
        b = (lng1 - lng2) * rad
        s = 2 * Math.asin(Math.sqrt( (Math.sin(a/2)**2) + Math.cos(radLat1) * Math.cos(radLat2)* (Math.sin(b/2)**2) ))
        s = s * earth_radius
        s = (s * 10000).round / 10000
      rescue Exception => e
        s = 99999999
      end
      s
    end

    def to_s
      "#{@lat}:#{@lon}"
    end
  end
end