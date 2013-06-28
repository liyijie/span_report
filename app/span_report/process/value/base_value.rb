# encoding: utf-8

module SpanReport::Process::Value
  class BaseValue

    attr_reader :pctime

    def initialize
      @value = nil
    end

    def getvalue
      @value ||= ""
    end

    # def getvalue params
    #   @value ||= ""
    # end

    def add_value ievalue, pctime=0, gps=nil
      unless (ievalue.nil? || ievalue == "")
        process ievalue
      end
    end

    def add_invalid_value ievalue, pctime=0, gps=nil
      
    end

    def process ievalue
      @value = ievalue
    end
  end
end