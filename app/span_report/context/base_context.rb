# encoding: utf-8

module SpanReport::Context
  class BaseContext
    attr_reader :input_log, :output_log, :function

    def initialize path
      @path = path
    end

    def load_config
      load_common
      load_relate
    end

    def load_common
      doc = Nokogiri::XML(open(CONFIG_FILE))
      doc.search("common").each do |common|
        @input_log = get_content common, "input_log"
        @output_log = get_content common, "output_log"
        @function = get_content common, "function"
      end
    end

    def get_content element, name
      content = ""
      node = element.search(name).first
      if node
        content = node.content.to_s.strip
      end
      content
    end

    def load_relate
      
    end

    def process
      puts "base process is doing nothing"
    end

  end
end