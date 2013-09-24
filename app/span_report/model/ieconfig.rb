module SpanReport::Model
  class Ieconfig
    include Singleton

    def init filename
      @doc = Nokogiri::XML(open(filename)).xpath('//List')
    end

    def get_segments iename
      segments = []
      return segments if @doc.nil?
      element = @doc.xpath("EUnit[@name='#{iename}']").first
      seg_value = element.get_attribute("segment") if element
      alias_name = element.get_attribute("mapnameroot") if element

      segments = seg_value.split(/\(|\)/)
      segments.select! { |segment| !segment.empty? }
      segments.map! do |segment|
        sections = segment.split(',')
        segment = {}
        segment[:alias] = alias_name
        segment[:min] = sections[0].to_f
        segment[:max] = sections[1].to_f
        color = sections[2].to_i
        segment[:color] = "ff" + "%06x" % color
        segment
      end
      [alias_name, segments]
    end

  end
end