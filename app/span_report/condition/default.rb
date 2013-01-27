# encoding: utf-8

module SpanReport::Condition
  class Default

    attr_reader :iename, :scope
    def initialize(iename="", scope="")
      @iename = iename
      @scope = scope
    end

    def type
      "default"
    end

    def parse
      true
    end

    def validate?(validate_datas)
      true
    end


    def to_s
      "{'#{@iename}','#{@relation}','#{@scope}'}"
    end
  end
end