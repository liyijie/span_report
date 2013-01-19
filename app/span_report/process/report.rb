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
      @relate_ies = {}
      @counter_ies = {}
      @ie_caches = {}
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
        @ie_caches[ie_name] = contents[ie_index]
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
    def get_kpi_value(kpi_name)
      value = @ie_caches[kpi_name]
      value ||= ""
    end

    ########################################
    #注册关联的IE
    ########################################
    def reg_relate_ie(condition)
      @relate_ies[condition.iename] = condition
    end

    ########################################
    #注册counter需要的IE
    ########################################
    def reg_counter_ie(condition)
      @counter_ies[condition.iename] = condition
    end

  end
  
end