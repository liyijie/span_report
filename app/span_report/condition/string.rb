# encoding: utf-8

module SpanReport::Condition
  class StringCondition < Default

    #scope的格式应该直接是一个数字，所以不用解析
    def parse
      @scope = @scope.strip
    end

    def type
      "string"
    end

    def validate?(validate_datas)
      result = false
      ievalue = validate_datas[@iename]

      if ievalue.strip == @scope
        result = true
      end
      SpanReport.logger.debug "string condition value is:#{@scope}, ievalue is:#{ievalue.strip}, string result is:#{result}"
      result
    end

    def to_s
      "{'#{@iename}','string','#{@scope}'}"
    end
  end
end