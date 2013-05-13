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
        @ie_caches[ie_name] = contents[ie_index] unless contents[ie_index].nil?

        if @counter_item_map.has_key? ie_name
          counter_items = @counter_item_map[ie_name]
          counter_items.each do |counter_item|
            #需要校验这条数据是否能满足counter item定义的条件
            next unless counter_item.validate? @ie_caches

            counter_name = counter_item.name
            counter_ievalue = contents[ie_index]
            count_mode = counter_item.count_mode

            #对不带file_group进行全局统计
            add_counter_cache counter_name, counter_ievalue, count_mode, pctime

            #如果file_group不为空，则需要再对file_group进行统计
            unless file_group.empty?
              group_counter_name = "#{file_group}##{counter_name}"
              add_counter_cache group_counter_name, counter_ievalue, count_mode, pctime
            end
          end
        end
      end
    end

    def add_counter_cache counter_name, counter_ievalue, count_mode, pctime=0
      unless @kpi_caches.has_key? counter_name
        @kpi_caches[counter_name] = SpanReport::Process::Value.create count_mode
      end
      
      report_value = @kpi_caches[counter_name]
      report_value.add_value counter_ievalue, pctime
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

    def count_kpi_value
      @kpi_items.each do |kpi_item|
        kpi_item.eval_value! @kpi_caches
      end
    end

    def clear
      @ie_caches = {}
      @kpi_caches = {}
    end
  end
end