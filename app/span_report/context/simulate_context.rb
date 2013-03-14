# encoding: utf-8

module SpanReport::Context
  class SimulateContext < BaseContext
    def load_relate
      doc = Nokogiri::XML(open(CONFIG_FILE))
      doc.search(@function).each do |relate|
        @cell_info = get_content relate, "cell_info"
      end
    end

    def process
      SpanReport::Model::Logformat.instance.load_xml "config/LogFormat_100.xml"
      cell_infos = SpanReport::Simulate::CellInfo
    end
  end
  
end