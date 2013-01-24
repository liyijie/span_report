# encoding: utf-8

module SpanReport::Model
  class CounterItem

    attr_accessor :name, :desc, :iename, :count_mode, :self_condition, :relate_conditions

    ###################################
    #excel配置文件中共有15列，分别是：
    #1.名称
    #2.描述
    #3.计算方式
    #4-6.自身条件
    #7-9.关联条件1
    #10-12.关联条件2
    #13-15.关联条件3
    ##################################
    def initialize(config_datas)
      @name = config_datas[0]
      @desc = config_datas[1]
      @count_mode = config_datas[2]

      @self_condition = SpanReport::Condition.create(config_datas[3], config_datas[4], config_datas[5])

      @iename = config_datas[3]
      relate_condition1 = SpanReport::Condition.create(config_datas[6], config_datas[7], config_datas[8])
      relate_condition2 = SpanReport::Condition.create(config_datas[9], config_datas[10], config_datas[11])
      relate_condition3 = SpanReport::Condition.create(config_datas[12], config_datas[13], config_datas[14])

      @relate_conditions = []
      @relate_conditions << relate_condition1 unless relate_condition1.instance_of? SpanReport::Condition::Default
      @relate_conditions << relate_condition2 unless relate_condition2.instance_of? SpanReport::Condition::Default
      @relate_conditions << relate_condition3 unless relate_condition3.instance_of? SpanReport::Condition::Default
    end

    #校验需要同时满足自身条件和关联条件，返回的结果才是true
    def validate?(validate_datas)
      result = self_condition.validate?(validate_datas)
      return false if (!result)
      relate_conditions.each do |relate_condition|
        result = relate_condition.validate(validate_datas)
        return false if (!result)
      end
      return true
    end

  end
end