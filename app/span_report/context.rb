# encoding: utf-8

module SpanReport
  module Context
    autoload :BaseContext, "span_report/context/base_context"
    autoload :NodebReportContext, "span_report/context/nodeb_report_context"
    autoload :ReportContext, "span_report/context/report_context"
    autoload :ExportContext, "span_report/context/export_context"
    autoload :SimulateContext, "span_report/context/simulate_context"
    autoload :LglconvertContext, "span_report/context/lglconvert_context"
    autoload :MapContext, "span_report/context/map_context"
    autoload :LglmergeContext, "span_report/context/lglmerge_context"

    CONFIG_FILE = "config/config.xml"


    def self.create path
      doc = Nokogiri::XML(open(CONFIG_FILE))
      doc.search("common").each do |common|
        @function = get_content common, "function"
      end

      if @function == "nodeb_report"
        context = NodebReportContext.new path
      elsif @function == "report"
        context = ReportContext.new path          
      elsif @function == "export"
        context = ExportContext.new path 
      elsif @function == "simulate"
        context = SimulateContext.new path
      elsif @function == "lglconvert"
        context = LglconvertContext.new path
      elsif @function == "map"
        context = MapContext.new path
      elsif @function == "lglmerge"
        context = LglmergeContext.new path
      else
        context = BaseContext.new path
      end

      context.load_config
      context

    end

    def self.get_content element, name
      content = ""
      node = element.search(name).first
      if node
        content = node.content.to_s.strip
      end
      content
    end

  end
  
end