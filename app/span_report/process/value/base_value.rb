# encoding: utf-8

module SpanReport::Process::Value
  class BaseValue

    def initialize
      @value = nil
      @pctime = 0
    end

    def getvalue
      @value ||= ""
    end

    # def getvalue params
    #   @value ||= ""
    # end

    def add_value ievalue, pctime=0
      unless (ievalue.nil? || ievalue == "")
        process ievalue
        @pctime = pctime
      end
    end

    def process ievalue
      @value = ievalue
    end
  end
end