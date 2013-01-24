# encoding: utf-8

module SpanReport::Process

  class Report < Base

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
    end

    ########################################
    #处理日志中的一条数据
    #这里已经通过校验，已经是包含需要处理的数据
    #1. 把日志数据中相关的IE都能加入到IE缓存中
    #2. 如果是counter相关的数据，则计算相关的counter值
    #
    #########################################
    def process_data logdata
      contents = logdata.split(/,|:/)
      group_id = contents[1].to_i
      needed_ies = get_needed_ies group_id

      needed_ies.each do |logitem|
        ie_name = logitem.name
        ie_index = logitem.index + 3
        @ie_caches[ie_name] = contents[ie_index] unless contents[ie_index].nil?

        if @counter_item_map.has_key? ie_name
          counter_items = @counter_item_map[ie_name]
          counter_items.each do |counter_item|
            counter_name = counter_item.name
            counter_ievalue = contents[ie_index]
            @kpi_caches[counter_name] = ReportValue.new unless @kpi_caches.has_key? counter_name
            report_value = @kpi_caches[counter_name]
            report_value.add_value counter_ievalue
          end
        end
      end
    end
    def reg_counter_item counter_item
      iename = counter_item.iename
      @counter_item_map[iename] ||= []
      @counter_item_map[iename] << counter_item
      reg_iename iename, iename

      # 注册相关联条件的IE
      relate_conditions = counter_item.relate_conditions
      relate_conditions.each do |condition|
        condition_iename = condition.iename
        reg_iename condition_iename condition_iename
      end
    end

    ########################################
    #根据报表模板中的KPI获取相关的值
    #这里需要注意的是，这里的名称是可以进行扩展的
    #基本的格式如下：
    #1. kpiname
    #2. logkey.kpiname
    #3. kpiname[1]
    #4. kpiname[0][1]
    #########################################
    def get_kpi_value(kpi_name, mode)
      reportvalue = @kpi_caches[kpi_name]
      if reportvalue
        value = reportvalue.getvalue mode
      end
      value ||= ""
    end
  end

  class ReportValue

    attr_accessor :max, :min, :count, :sum, :recent

    def initialize
      @max = nil
      @min = nil
      @count = 0
      @sum = 0.0
      @recent = nil
    end

    def add_value ievalue
      return if ievalue.nil? || ievalue.empty?
      # max
      @max = ievalue.to_f if @max.nil?
      @max = ievalue.to_f if @max < ievalue.to_f
      # min
      @min = ievalue.to_f if @min.nil?
      @min = ievalue.to_f if @min > ievalue.to_f
      # count
      @count += 1
      # sum
      @sum += ievalue.to_f
      # recent
      @recent = ievalue.to_f
    end

    def avg
      if @count == 0
        value = "N/A" 
      else
        value = @sum / @count
      end
    end

    def getvalue mode
      case mode
      when "max"
        value = max
      when "min"
        value = min
      when "sum"
        value = sum
      when "avg"
        value = avg
      when "recent"
        value = recent
      end
      value ||= ""
    end
    
  end
  
end