# encoding: utf-8

require "span_report/cache"
require "span_report/counter_def"
require "nokogiri"

module SpanReport
   autoload :Condition, "span_report/condition"
   autoload :Model, "span_report/model"
   autoload :Logfile, "span_report/logfile"
   autoload :Process, "span_report/process"
end


SpanReport::Model::Logformat.instance.load_xml "config/LogFormat_100.xml"
export = SpanReport::Process::Export.new
["TDDLTE_L1_measurement_Serving_Cell_Measurement_RSRP", 
  "TDDLTE_L1_measurement_Serving_Cell_Measurement_SINR"].each do |iename|
  export.reg_iename iename
end

filereader = SpanReport::Logfile::FileReader.new("config/leadcore-gps-ftp.lgl")
filereader.parse(export)
export.write_result("result.csv")

