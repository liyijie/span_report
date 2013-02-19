# encoding: utf-8

module SpanReport
  module Condition
    autoload :Default, "span_report/condition/default"
    autoload :Equal, "span_report/condition/equal"
    autoload :Range, "span_report/condition/range"
    autoload :Section, "span_report/condition/section"
    autoload :ArrayCondition, "span_report/condition/array"
    autoload :StringCondition, "span_report/condition/string"

    def self.create(iename, relation, scope)
      if relation == 'range'
        condition = Range.new(iename, scope)
      elsif relation == 'equal'
        condition = Equal.new(iename, scope)
      elsif relation == 'section'
        condition = Section.new(iename, scope)
      elsif relation == 'array'
        condition = ArrayCondition.new(iename, scope)
      elsif relation == 'string'
        condition = StringCondition.new(iename, scope)  
      else
        condition = Default.new(iename, scope)
      end
      condition.parse
      condition
    end
        
  end
end