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
      begin
        worksheet = workbook.Worksheets('Counter定义')
        row_count = worksheet.UsedRange.Rows.count

        worksheet.Range("a3:o#{row_count}").Rows.each do |row|
          config_datas = row.Value[0]
          next if config_datas[0].nil?

          counter_item = CounterItem.new config_datas

          result_items = []
          expend_self_items = expend_self counter_item

          if counter_item.relate_conditions.size ==1
            expend_relate1_items = []
            expend_self_items.each do |item|
              expend_relate1_items.concat(expend_relate(item, 0))
            end
            result_items = expend_relate1_items 
          elsif counter_item.relate_conditions.size ==2
            expend_relate1_items = []
            expend_self_items.each do |item|
              expend_relate1_items.concat(expend_relate(item, 0))
            end

            expend_relate2_items = []
            expend_relate1_items.each do |item|
              expend_relate2_items.concat(expend_relate(item, 1))
            end

            result_items = expend_relate2_items
          elsif counter_item.relate_conditions.size ==3
            expend_relate1_items = []
            expend_self_items.each do |item|
              expend_relate1_items.concat(expend_relate(item, 0))
            end

            expend_relate2_items = []
            expend_relate1_items.each do |item|
              expend_relate2_items.concat(expend_relate(item, 1))
            end

            expend_relate3_items = []
            expend_relate2_items.each do |item|
              expend_relate3_items.concat(expend_relate(item, 2))
            end
            result_items = expend_relate3_items
          else
            result_items = expend_self_items
          end

          @counter_items.concat result_items
        end
        @counter_items.each do |item|
          SpanReport.logger.debug item
        end
      rescue Exception => e
        SpanReport.logger.error e
      ensure
        workbook.close
      end
    end

    #扩展数组、扩展分段
    def expend_self counter_item
      #处理self-condition，包括数组和section
      self_condition = counter_item.self_condition
      result_items = []
      if self_condition.type == "array"
        array_length = self_condition.length
        (0..array_length-1).each do |index|
          new_item = counter_item.clone
          name = "#{counter_item.name}_#{index}"
          iename = "#{counter_item.iename}_#{index}"
          new_item.name = name
          new_item.iename = iename
          new_item.self_condition = SpanReport::Condition.create(iename, "", "")
          result_items << new_item
        end
      elsif self_condition.type == "section"
        sections = self_condition.sections
        sections.each_with_index do |range, index|
          new_item = counter_item.clone
          name = "#{counter_item.name}[#{index}]"
          iename = counter_item.iename
          new_item.name = name
          new_item.self_condition = SpanReport::Condition.create(iename, "range", range)
          result_items << new_item
        end
      else
        result_items << counter_item
      end
      result_items
    end

    def expend_relate counter_item, level
      result_items = []
      relate_condition = counter_item.relate_conditions[level.to_i]
      relate_conditions = counter_item.relate_conditions
      if relate_condition.type == "section"
        sections = relate_condition.sections
        sections.each_with_index do |range, index|
          new_item = counter_item.clone
          name = "#{counter_item.name}[#{index}]"
          iename = relate_condition.iename
          new_item.name = name
          new_item.relate_conditions[level.to_i] = SpanReport::Condition.create(iename, "range", range)
          result_items << new_item
        end
      else
        result_items << counter_item
      end
      result_items

    end

  end  
end