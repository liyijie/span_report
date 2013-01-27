# encoding: utf-8
require 'win32ole'

module SpanReport::Process
  # class Report
    class ReportExport
      def initialize template_file
        @template_file = template_file
      end

      def to_excel resultfile, kpi_caches
        excel = WIN32OLE::new('excel.Application')
        workbook = excel.Workbooks.Open @template_file
        begin
          workbook.Worksheets.each do |worksheet|
            worksheet.UsedRange.each do |cell|
              if cell.Value =~ /^<.*>$/
                kpiname = cell.Value
                kpiname = kpiname.sub '<', ''
                kpiname = kpiname.sub '>', ''
                cell.Value = kpi_caches.get_kpi_value kpiname
              end
            end
          end
          workbook.SaveAs resultfile
        rescue Exception => e
          SpanReport.logger.error e
        ensure
          workbook.close
        end
      end
    end
  # end
end