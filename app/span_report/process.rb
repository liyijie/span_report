# encoding: utf-8

module SpanReport
  module Process
    autoload :Base, "span_report/process/base"
    autoload :Export, "span_report/process/export"
    autoload :Report, "span_report/process/report"
    autoload :NodebReport, "span_report/process/nodeb_report"
    autoload :Value, "span_report/process/value"
    autoload :ReportExport, "span_report/process/report_export"
    autoload :NodebReportExport, "span_report/process/nodeb_report_export"
  end
end