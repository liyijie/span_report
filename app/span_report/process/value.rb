# encoding: utf-8

module SpanReport::Process
  module Value
    autoload :BaseValue, "span_report/process/value/base_value"
    autoload :Avg, "span_report/process/value/avg"
    autoload :Count, "span_report/process/value/count"
    autoload :Max, "span_report/process/value/max"
    autoload :Min, "span_report/process/value/min"
    autoload :Recent, "span_report/process/value/recent"

    def self.create mode
      if mode == 'avg'
        value = Avg.new
      elsif mode == 'count'
        value = Count.new
      elsif mode == 'max'
        value = Max.new
      elsif mode == 'min'
        value = Min.new
      elsif mode == 'recent'
        value = Recent.new
      else
        value = BaseValue.new
      end
      value
    end
  end
end