# encoding: utf-8

module SpanReport::Condition
  class Default

    def initialize(iename="", scope="")
      @iename = iename
      @scope = scope
    end

    def parse
      true
    end

    def validate?(validate_datas)
      true
    end
  end
end