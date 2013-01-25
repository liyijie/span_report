# encoding: utf-8

module SpanReport::Process::Value
  class Max < BaseValue

    def process ievalue
      @value = ievalue.to_f if @value.nil?
      @value = ievalue.to_f if @value < ievalue.to_f
    end

  end
end