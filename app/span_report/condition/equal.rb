# encoding: utf-8

module SpanReport::Condition
  class Equal < Default

    #scope的格式应该直接是一个数字，所以不用解析
    def parse
      true
    end

    def validate?(validate_datas)
      result = false
      ievalue = validate_datas[@iename]
      if ievalue == @scope
        result = true
        result
      end
    end
  end
end