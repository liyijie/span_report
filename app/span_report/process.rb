# encoding: utf-8

module SpanReport
  module Process
    autoload :Base, "span_report/process/base"
    autoload :Export, "span_report/process/export"
    autoload :Report, "span_report/process/report"
    autoload :Value, "span_report/process/value"
  end
end