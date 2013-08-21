#encoding: utf-8
# require 'win32ole'
require "smarter_csv"

module SpanReport::Simulate
  class CellInfos
    attr :cell_infos

    def initialize
      # 其中cellinfos是按照pci和freq来作为key存储cellinfo
      # 其中因为pci和freq并不是唯一的，因此获取的应该是一个list
      @cell_infos_map = {}
      @cellname_infos_map = {}
    end

    def load_from_xls csv_file
      
      SmarterCSV.process(csv_file, file_encoding: 'gbk') do |data|
        next if data.first[:pci].to_s.encode("utf-8").empty?

        cell_info = CellInfo.new
        cell_info.nodeb_name = data.first[:sitename].to_s.encode("utf-8")
        cell_info.cell_name = data.first[:cellname].to_s.encode("utf-8")
        cell_info.pci = data.first[:pci].to_s.encode("utf-8")
        cell_info.freq = data.first[:frequency_dl].to_s.encode("utf-8")
        cell_info.lat = data.first[:latitude].to_s.encode("utf-8")
        cell_info.lon = data.first[:longitude].to_s.encode("utf-8")
        cell_info.high = data.first[:high].to_s.encode("utf-8")
        cell_info.angle = data.first[:tilt_total].to_s.encode("utf-8")
        
        add_cellinfo cell_info
      end
    end

    def get_cellinfos pci, freq
      cell_key = "#{pci.to_i}_#{freq.to_i}"
      cell_infos = @cell_infos_map[cell_key]
      cell_infos ||= []
    end

    def get_cellinfo cell_name
      @cellname_infos_map[cell_name]
    end

    def add_cellinfo cellinfo
      if cellinfo
        cell_key = "#{cellinfo.pci.to_i}_#{cellinfo.freq.to_i}"
        @cell_infos_map[cell_key] ||= []
        @cell_infos_map[cell_key] << cellinfo

        @cellname_infos_map[cellinfo.cell_name] = cellinfo
      end
    end

  end

  class CellInfo
    attr_accessor :pci, :freq, :nodeb_name, :cell_name, :lat, :lon, :high, :angle 
    def initialize
      @pci = ""
      @freq = ""
      @nodeb_name = ""
      @cell_name = ""
      @lat = 0
      @lon = 0
      @high = 0
      @angle = 0
    end

    # def to_s
      
    # end
  end
end