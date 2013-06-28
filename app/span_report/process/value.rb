# encoding: utf-8

module SpanReport::Process
  module Value
    autoload :BaseValue, "span_report/process/value/base_value"
    autoload :Avg, "span_report/process/value/avg"
    autoload :Count, "span_report/process/value/count"
    autoload :Max, "span_report/process/value/max"
    autoload :Min, "span_report/process/value/min"
    autoload :Recent, "span_report/process/value/recent"
    autoload :Sum, "span_report/process/value/sum"
    autoload :Cdf, "span_report/process/value/cdf"
    autoload :Time, "span_report/process/value/time"
    autoload :Distance, "span_report/process/value/distance"
    autoload :DistanceCondition, "span_report/process/value/distance_condition"

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
      elsif mode == 'sum'
        value = Sum.new
      elsif mode =~ /^cdf/
        value = Cdf.new mode
      elsif mode =~ /^time/
        value = Time.new mode
      elsif mode == 'distance'
        value = Distance.new mode
      elsif mode =~ /^distance\(/
        value = DistanceCondition.new mode
      else
        value = BaseValue.new
      end
      value
    end
  end
end