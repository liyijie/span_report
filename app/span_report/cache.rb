# encoding: utf-8

module SpanReport
  class Cache
    def initialize
      @relate_ies = {}
      @counter_ies = {}
    end

    ########################################
    #根据报表模板中的KPI获取相关的值
    #这里需要注意的是，这里的名称是可以进行扩展的
    #基本的格式如下：
    #1. <kpiname>
    #2. <logkey.kpiname>
    #########################################
    def get_kpi_value(kpi_name)

    end

    ########################################
    #增加一条log数据
    #先判断这条数据是否是报表相关的，如果不是需要的，这条数据可以直接舍弃
    ########################################
    def add_logdata(logdata)
      
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

    private:

    def data_needed?
      
    end

    def method_name
      
    end
  end
  
end