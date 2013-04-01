# encoding: utf-8

module SpanReport
  module Logfile
    autoload :FileReader, "span_report/logfile/file_reader"
    autoload :CsvReader, "span_report/logfile/csv_file_operate"
    autoload :CsvWriter, "span_report/logfile/csv_file_operate"
  end
end