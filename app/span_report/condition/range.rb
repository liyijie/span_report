# encoding: utf-8

module SpanReport::Condition
  class Range < Default

    # [-1,0) (-1,0], (-1,0), [-1,0]"
    def parse
      @scope = @scope.gsub(' ', '')
      
      parse_result = false
      if @scope=~/^(\[|\().*,.*(\]|\))$/
        @low_mark = $1
        @high_mark = $2
        contents = @scope.split(/\[|\]|\(|\)|,/)
        @low_num = contents[1].to_f
        @high_num = contents[2].to_f
        parse_result = true
      end
      
      parse_result
    end

    def type
      "range"
    end

    def validate?(validate_datas)
      ievalue = validate_datas[@iename]
      
      return_value = false
      if ievalue
        ievalue = ievalue.to_f
        if (ievalue > @low_num && ievalue < @high_num)
          return_value = true
        elsif @low_mark == '[' && ievalue == @low_num
          return_value = true
        elsif @high_mark == ']' && ievalue == @high_num
          return_value = true
        end
      end
      return_value
    end

    def to_s
      "{'#{@iename}','range','#{@scope}'}"
    end
  end
end