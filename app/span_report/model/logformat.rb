# encoding: utf-8
require "singleton"

module SpanReport::Model
  class Logformat
    include Singleton

    attr_reader :group_map, :item_map
    def initialize
      @group_map = {}
      @item_map = {}

   end

   def load_xml(xml_file)
    doc = Nokogiri::XML(open(xml_file))
    @group_map = {}
    @item_map = {}

    doc.search("LogLine").each do |logline|
      logline_index = logline.get_attribute("Index").to_i
      @group_map[logline_index] = Array.new

      logline.search("LogItem").each_with_index do |item, index|
        name = item.get_attribute("Alias");
        name = item.get_attribute("Name") unless name
        type = item.get_attribute("Type")
        logitem = LogItem.new(logline_index, index, name, type)
        @group_map[logline_index] << logitem
        @item_map[name.downcase] = logitem
      end
    end
  end

  def get_logitem(iename)
    @item_map[iename.downcase]
  end
end

end