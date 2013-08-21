# encoding: utf-8
# require 'win32ole'
require "smarter_csv"

module SpanReport::Process
  class NodebReportExport
    attr_accessor :cell_infos

    def initialize template_file
      @template_file = template_file
      @cell_infos = []
    end

    def to_excel resultfile, kpi_caches, nodeb_cell_info
      resultfile = resultfile.gsub(/\//, "\\\\")
      puts "save file:#{resultfile}"
      excel = WIN32OLE::new('excel.Application')
      workbook = excel.Workbooks.Open @template_file
      begin
        workbook.Worksheets.each do |worksheet|
          worksheet.UsedRange.each do |cell|
            kpiname = cell.Value.to_s
            kpiname = kpiname.encode "utf-8"
            if kpiname =~ /^<.*>$/
              if kpiname =~ /<[^\$<>]*\$/
                # kpiname = kpiname.gsub(/<[\w\[\]]*\$/) do |match|
                kpiname = kpiname.gsub(/<[^\$<>]*\$/) do |match|
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
            elsif kpiname =~ /^{.*}$/
              #this is eval kpi
              kpiname = kpiname.gsub(/<[^\$<>]*\$/) do |match|
                info_name = match
                info_name = info_name.sub '<', ''
                info_name = info_name.sub '$', ''
                match = match.sub info_name, nodeb_cell_info[info_name].to_s
              end
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
        puts e.backtrace.join("\n")
      ensure
        workbook.close
      end
    end

    def to_excels result_path, kpi_caches
      nodeb_info_map = trans_to_nodeb_info_map @cell_infos
      relate_nodebs = kpi_caches.relate_nodebs

      relate_nodebs.each do |nodeb_name|
        cell_infos = nodeb_info_map[nodeb_name]
        cell_infos ||= []
        resultfile = File.join result_path, "#{nodeb_name}_单站验证报告.xlsx"
        nodeb_cell_info = {}
        nodeb_cell_info["nodeb"] = nodeb_name
        cell_infos.each_with_index do |cell_info, index|
          nodeb_cell_info["cell#{index+1}"] = cell_info.cell_name
        end
        to_excel resultfile, kpi_caches, nodeb_cell_info
      end
    end

    #从excel获取小区表的相关信息
    def load_cell_infos csv_file
      begin
        SmarterCSV.process(csv_file, file_encoding: 'gbk') do |data|
          next if data.first[:pci].to_s.encode("utf-8").empty?

          cell_info = CellInfo.new
          cell_info.nodeb_name = data.first[:sitename].to_s.encode("utf-8")
          cell_info.cell_name = data.first[:cellname].to_s.encode("utf-8")
          cell_info.pci = data.first[:pci].to_s.encode("utf-8")
          cell_info.freq = data.first[:frequency_dl].to_s.encode("utf-8")
          cell_info.lat = data.first[:latitude].to_s.encode("utf-8")
          cell_info.lon = data.first[:longitude].to_s.encode("utf-8")
          @cell_infos << cell_info
        end
      rescue Exception => e
        SpanReport.logger.error e
        puts e
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
      attr_accessor :nodeb_name, :cell_name, :pci, :freq, :lat, :lon

      def initialize
        
      end
    end
  end
end