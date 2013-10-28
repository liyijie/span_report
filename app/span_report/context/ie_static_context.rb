# encoding: utf-8
require "smarter_csv"
require 'set'

module SpanReport::Context
  class IeStaticContext < BaseContext

    def load_relate
      doc = Nokogiri::XML(open(CONFIG_FILE))
      doc.search(@function).each do |relate|
        @ieconfigs = {}
        relate.search("ie").each do |ie|
          ie_name = ie.get_attribute("name")
          ie_section = get_content ie, "section"
          ie_pdf_cdf = get_content ie, "pdf_cdf"
          @ieconfigs[ie_name] = {}
          @ieconfigs[ie_name][:section] = ie_section
          @ieconfigs[ie_name][:pdf_cdf] = ie_pdf_cdf
        end
      end
    end

    def process
      # reg ie counter items
      report = SpanReport::Process::Report.new
      @ieconfigs.each do |ie_name, ie_item|
        counter_items = create_ie_items ie_name, ie_item
        counter_items.each do |counter_item|
          report.reg_counter_item counter_item
        end
      end

      # open map.csv file and process the data
      ue_set = Set.new
      map_file = File.join @input_log, "map.csv"
      MapCsv.foreach(map_file) do |data|
        next if data[:pctime].to_i <= 0
        ueid = data[:ueid].to_i
        next if ueid < 1
        ue_set << ueid
        pctime = data[:pctime].to_s
        ie_map = data.select do |key, value|
          key.to_s.start_with? "i"
        end
        report.process_ies ueid, ie_map, pctime
      end

      # store the result
      static_result = []
      @ieconfigs.each do |ie_name, ie_item|
        
        static_value = create_static_value report,ie_name, "all"
        static_result << static_value
        ue_set.each do |ueid|
          static_value_ue = create_static_value report, ie_name, ueid
          static_result << static_value_ue
        end
      end

      # write the result file
      result_file = File.join @output_log, "ie_static.csv"
      File.open(result_file, "w") do |file|
        file.puts StaticValue.head
        static_result.each do |static_value|
          file.puts static_value if static_value.count.to_i > 0
        end
      end
    end


    def create_static_value report, ie_name, ueid
      static_value = StaticValue.new
      static_value.name = ie_name
      static_value.ueid = ueid
      prefex = ueid.to_i > 0 ? "#{ueid}#" : ""
      static_value.max = report.get_kpi_value "#{prefex}#{ie_name}_max"
      static_value.min = report.get_kpi_value "#{prefex}#{ie_name}_min"
      static_value.avg = report.get_kpi_value "#{prefex}#{ie_name}_avg"
      static_value.count = report.get_kpi_value "#{prefex}#{ie_name}_count"
      static_value.pdf = report.get_kpi_value "#{prefex}#{ie_name}_pdf_cdf(pdf)"
      static_value.cdf = report.get_kpi_value "#{prefex}#{ie_name}_pdf_cdf(cdf)"

      sections = []
      (0..8).each do |index|
        kpi_key = "#{prefex}#{ie_name}_range[#{index}]"
        break unless report.has_kpi_value? kpi_key
        value = report.get_kpi_value kpi_key
        sections << value
      end
      static_value.section = sections.join ";"
      static_value
    end



    # max, min, avg, count, section(count), pdf, cdf
    def create_ie_items ie_name, ie_item
      ie_section = ie_item[:section]
      ie_pdf_cdf = ie_item[:pdf_cdf]

      counter_items = []

      ["max", "min", "avg", "count"].each do |mode|
        config_datas = []
        config_datas[0] = "#{ie_name}_#{mode}"
        config_datas[1] = ""
        config_datas[2] = mode
        config_datas[3] = ie_name
        counter_items << SpanReport::Model::CounterItem.new(config_datas)
      end

      # section
      sections = ie_section.split(';')
      sections.each_with_index do |range, index|
        config_datas = []
        config_datas[0] = "#{ie_name}_range[#{index}]"
        config_datas[1] = ""
        config_datas[2] = "count"
        config_datas[3] = ie_name
        config_datas[4] = "range"
        config_datas[5] = range
        range_counter_item = SpanReport::Model::CounterItem.new(config_datas)
        counter_items << range_counter_item
      end

      # pdf_cdf
      config_datas = []
      config_datas[0] = "#{ie_name}_pdf_cdf"
      config_datas[1] = ""
      config_datas[2] = "pdf_cdf#{ie_pdf_cdf}"
      config_datas[3] = ie_name
      counter_items << SpanReport::Model::CounterItem.new(config_datas)
    end

  end

  class StaticValue
    
    attr_accessor :name, :ueid, :max, :min, :avg, :count, :section, :pdf, :cdf

    def self.head
      "name,ueid,max,min,avg,count,section,pdf,cdf"  
    end

    def to_s
      "#{name},#{ueid},#{max},#{min},#{avg},#{count},#{section},#{pdf},#{cdf}"
    end
  end
  
end