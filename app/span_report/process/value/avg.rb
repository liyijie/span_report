# encoding: utf-8

module SpanReport::Process::Value
  class Avg < BaseValue

    def initialize
      @count = 0
      @sum = 0.0
    end

    def process ievalue
      @count += 1
      @sum += ievalue.to_f
    end

    def getvalue
      value = ""
      if @count == 0
        value = ""
      else
        value = @sum/@count
      end
      value
    end
    
  end
end