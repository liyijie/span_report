# encoding: utf-8
class CellCsv

  def self.foreach(input, options={}, &block)
    cell_infos = []
    SmarterCSV.process(input, file_encoding: 'gbk') do |data|
      next if data.first[:pci].to_s.encode("utf-8").empty?
      cell_info = {}
      cell_info[:sitename] = data.first[:sitename].to_s.encode("utf-8")
      cell_info[:cellname] = data.first[:cellname].to_s.encode("utf-8")
      cell_info[:pci] = data.first[:pci]
      cell_info[:frequency_dl] = data.first[:frequency_dl]
      cell_info[:latitude] = data.first[:latitude]
      cell_info[:longitude] = data.first[:longitude]
      cell_info[:high] = data.first[:high]
      cell_info[:tilt_total] = data.first[:tilt_total]
      cell_info[:azimuth] = data.first[:azimuth]

      yield cell_info if block_given?
      cell_infos << cell_info
    end
    cell_infos
  end
  
end