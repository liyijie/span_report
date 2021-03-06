# encoding: utf-8
require 'win32ole'

module SpanReport::Process

    class ReportExport
      def initialize template_file
        @template_file = template_file
      end

      def to_excel resultfile, kpi_caches
        resultfile = resultfile.gsub(/\//, "\\\\")

        puts "result file:#{resultfile}"
        excel = WIN32OLE::new('excel.Application')
        workbook = excel.Workbooks.Open @template_file
        begin
          workbook.Worksheets.each do |worksheet|
            worksheet.UsedRange.each do |cell|
              kpiname = cell.Value.to_s
              kpiname = kpiname.encode "utf-8"
              if kpiname =~ /^<.*>$/
                kpiname = kpiname.sub '<', ''
                kpiname = kpiname.sub '>', ''
                cell.Value = kpi_caches.get_kpi_value kpiname
              elsif kpiname =~ /^{.*}$/
                #this is eval kpi
                kpiname = kpiname.sub '{', ''
                kpiname = kpiname.sub '}', ''
                kpi_item = SpanReport::Model::KpiItem.new(["", "", kpiname])
                value = kpi_item.eval_value kpi_caches.kpi_caches
                cell.Value = value
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

end