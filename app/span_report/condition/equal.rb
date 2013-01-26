# encoding: utf-8

module SpanReport::Condition
  class Equal < Default

    #scope的格式应该直接是一个数字，所以不用解析
    def parse
      @scope = @scope.to_f
    end

    def validate?(validate_datas)
      result = false
      ievalue = validate_datas[@iename]
      
      if ievalue.to_f == @scope.to_f
        result = true
      end
      result
    end

    def to_s
      "{'#{@iename}','equal','#{@scope}'}"
    end
  end
end