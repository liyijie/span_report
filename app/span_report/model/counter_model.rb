# encoding: utf-8
require 'win32ole'

module SpanReport::Model

  class CounterModel

    attr_reader :counter_items

    def initialize
      @counter_items = []
    end
    
    def parse model_file
      excel = WIN32OLE::new('excel.Application')
      workbook = excel.Workbooks.Open model_file
      worksheet = workbook.Worksheets('Counter定义')
      row_count = worksheet.UsedRange.Rows.count

      worksheet.Range("a3:o#{row_count}").Rows.each do |row|
        config_datas = row.Value[0]
        next if config_datas[0].nil?
        counter_item = CounterItem.new config_datas
        @counter_items << counter_item
      end
      workbook.close
    end
  end  
end