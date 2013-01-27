# encoding: utf-8

module SpanReport::Condition
  class ArrayCondition < Default

    attr_reader :length

    #scope的格式应该直接是一个数字，是数组的长度
    def parse
      @length = @scope.to_i
    end

    def type
      "array"
    end

    def validate?(validate_datas)
      true
    end

    def to_s
      "{'#{@iename}','array','#{@scope}'}"
    end
  end
end