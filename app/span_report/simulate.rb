# encoding: utf-8

module SpanReport
  module Simulate
    autoload :AnaData, "span_report/simulate/ana_data"
    autoload :HoldlastData, "span_report/simulate/ana_data"
    autoload :PointData, "span_report/simulate/ana_data"
    autoload :CellInfos, "span_report/simulate/cell_infos"
    autoload :SimulateProcess, "span_report/simulate/simulate_process"
    autoload :ConvertFileProcess, "span_report/simulate/convert_file_process"
  end
end