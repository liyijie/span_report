# encoding: utf-8

module SpanReport
  module Condition
    autoload :Default, "span_report/condition/default"
    autoload :Equal, "span_report/condition/equal"
    autoload :Range, "span_report/condition/range"
    autoload :Section, "span_report/condition/section"

    def self.create(iename, relation, scope)
      if type == 'range'
        condition = Range.new(iename, scope)
      elsif type == 'section'
        condition = Section.new(iename, scope)
      elsif type == 'equal'
        condition = Equal.new(iename, scope)
      else
        condition = Base.new(iename, scope)
      end
        condition.parse
        condition
    end
        
  end
end