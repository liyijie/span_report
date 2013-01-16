# encoding: utf-8

module SpanReport
  class CounterDef

    attr_accessor :name, :desc, :iename, :self_condition, :relate_conditions

    def initialize
      
    end

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