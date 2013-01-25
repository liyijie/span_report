# encoding: utf-8

module SpanReport::Process::Value
  class Recent < BaseValue

    def process ievalue
      @value = ievalue
    end

  end
end