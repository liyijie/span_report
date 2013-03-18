#encoding: utf-8
require 'win32ole'

module SpanReport::Simulate
  class CellInfos
    attr :cell_infos

    def initialize
      # 其中cellinfos是按照pci和freq来作为key存储cellinfo
      # 其中因为pci和freq并不是唯一的，因此获取的应该是一个list
      @cell_infos_map = {}
    end

    def load_from_xls excelfile
      begin
        excel = WIN32OLE::new('excel.Application')
        workbook = excel.Workbooks.Open excelfile
        worksheet = workbook.Worksheets('cell_info')
        row_count = worksheet.UsedRange.Rows.count

        worksheet.Range("a2:f#{row_count}").Rows.each do |row|
          config_datas = row.Value[0]
          next if config_datas[0].nil?
          cell_info = CellInfo.new

          cell_info.nodeb_name = config_datas[0].to_s.encode("utf-8")
          cell_info.cell_name = config_datas[1].to_s.encode("utf-8")
          cell_info.pci = config_datas[2].to_s.encode("utf-8")
          cell_info.freq = config_datas[3].to_s.encode("utf-8")
          cell_info.lat = config_datas[4].to_s.encode("utf-8")
          cell_info.lon = config_datas[5].to_s.encode("utf-8")
          add_cellinfo cell_info
        end
      rescue Exception => e
        SpanReport.logger.error e
        puts e
      ensure
        workbook.close
      end
    end

    def get_cellinfos pci, freq
      cell_key = "#{pci.to_i}_#{freq.to_i}"
      cell_infos = @cell_infos_map[cell_key]
      cell_infos ||= []
    end

    def add_cellinfo cellinfo
      if cellinfo
        cell_key = "#{cellinfo.pci.to_i}_#{cellinfo.freq.to_i}"
        @cell_infos_map[cell_key] ||= []
        @cell_infos_map[cell_key] << cellinfo
      end
    end

  end

  class CellInfo
    attr_accessor :pci, :freq, :nodeb_name, :cell_name, :lat, :lon 
    def initialize
      @pci = ""
      @freq = ""
      @nodeb_name = ""
      @cell_name = ""
      @lat = 0
      @lon = 0
    end
  end
end