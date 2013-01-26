# encoding: utf-8

module SpanReport::Model
  class LogItem
    attr_accessor :group, :index, :name, :type

    # group: group number
    # index: index in the group
    # name:  name of the ie
    # type:  type of the ie, double or string
    def initialize(group, index, name, type)
      @group = group
      @index = index
      @name = name
      @type = type
    end

    def equal? other
      @name == other.name
    end

  end
end