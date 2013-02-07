# encoding: utf-8

module SpanReport::Process::Value
  class Sum < BaseValue

    def process ievalue
      @value = 0.0 if @value.nil?
      @value += ievalue.to_f
    end
    
  end
end