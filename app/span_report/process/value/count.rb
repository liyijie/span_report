# encoding: utf-8

module SpanReport::Process::Value
  class Count < BaseValue

    def initialize
      @value = 0
    end

    def process ievalue
      @value += 1
    end

    def getvalue
      @value ||= 0
    end
  end
end