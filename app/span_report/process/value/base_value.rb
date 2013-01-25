# encoding: utf-8

module SpanReport::Process::Value
  class BaseValue

    def initialize
      @value = nil
    end

    def getvalue
      @value ||= ""
    end

    def add_value ievalue
      process ievalue unless (ievalue.nil? || ievalue.empty?)
    end

    def process ievalue
      
    end
  end
end