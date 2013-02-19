# encoding: utf-8
require 'win32ole'

module SpanReport::Process
  class NodebReportExport
    attr_accessor :cell_infos

    def initialize template_file
      @template_file = template_file
      @cell_infos = []
    end

    def to_excel resultfile, kpi_caches, nodeb_cell_info
      puts "save file:#{resultfile}"
      excel = WIN32OLE::new('excel.Application')
      workbook = excel.Workbooks.Open @template_file
      begin
        workbook.Worksheets.each do |worksheet|
          worksheet.UsedRange.each do |cell|
            kpiname = cell.Value.to_s
            if kpiname =~ /^<.*>$/
              kpiname = cell.Value.to_s
              if kpiname =~ /<[\w\[\]]*\$/
                kpiname = kpiname.gsub(/<[\w\[\]]*\$/) do |match|
                  info_name = match
                  info_name = info_name.sub '<', ''
                  info_name = info_name.sub '$', ''
                  match = match.sub info_name, nodeb_cell_info[info_name].to_s
                end
              end
              kpiname = kpiname.sub '<', ''
              kpiname = kpiname.sub '>', ''
              if kpiname =~ /\$$/
                cell.Value = kpiname.sub '$', ''
              else
                cell.Value = kpi_caches.get_kpi_value kpiname
              end
            end
          end
        end
      rescue Exception => e
        SpanReport.logger.error e
        puts e.backtrace.join("\n")
      ensure
        workbook.SaveAs resultfile
        workbook.close
      end
    end

    def to_excels result_path, kpi_caches
      nodeb_info_map = trans_to_nodeb_info_map @cell_infos
      # puts "nodeb_info_map is: #{nodeb_info_map.inspect}"
      nodeb_info_map.each do |nodeb_name, cell_infos|
        resultfile = "#{result_path}/#{nodeb_name}_单站验证报告.xlsx"
        puts "result file is:#{resultfile}"
        nodeb_cell_info = {}
        nodeb_cell_info["nodeb"] = nodeb_name
        cell_infos.each_with_index do |cell_info, index|
          nodeb_cell_info["cell#{index+1}"] = cell_info.cell_name
        end
        to_excel resultfile, kpi_caches, nodeb_cell_info
      end
    end

    #从excel获取小区表的相关信息
    def load_cell_infos excelfile
      begin
        excel = WIN32OLE::new('excel.Application')
        workbook = excel.Workbooks.Open excelfile
        worksheet = workbook.Worksheets('cell_info')
        row_count = worksheet.UsedRange.Rows.count

        worksheet.Range("a2:d#{row_count}").Rows.each do |row|
          config_datas = row.Value[0]
          next if config_datas[0].nil?
          cell_info = CellInfo.new

          cell_info.nodeb_name = config_datas[0].to_s.encode("utf-8")
          cell_info.cell_name = config_datas[1].to_s.encode("utf-8")
          cell_info.pci = config_datas[2].to_s.encode("utf-8")
          cell_info.freq = config_datas[3].to_s.encode("utf-8")
          @cell_infos << cell_info
        end
      rescue Exception => e
        SpanReport.logger.error e
      ensure
        workbook.close
      end
    end

    def trans_to_nodeb_info_map cell_infos
      nodeb_info_map = {}
      cell_infos.each do |cell_info|
        nodeb_name = cell_info.nodeb_name
        
        unless nodeb_info_map.has_key? nodeb_name
          nodeb_info_map[nodeb_name] = []
        end
        
        nodeb_info_map[nodeb_name] << cell_info
      end
      nodeb_info_map
    end

    class CellInfo
      attr_accessor :nodeb_name, :cell_name, :pci, :freq

      def initialize
        
      end
    end
  end
end