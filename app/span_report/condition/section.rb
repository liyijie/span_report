# encoding: utf-8

module SpanReport::Condition
  class Section < Default

    # section condition is a list of range conditions
    attr_reader :sections

    def parse
      @sections = []
      @sections = @scope.split ";"
    end

    def type
      "section"
    end

    def validate?(validate_datas)
      true
    end

    def to_s
      "{'#{@iename}','section','#{@scope}'}"
    end
  end
end