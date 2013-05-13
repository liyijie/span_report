# encoding: utf-8

module SpanReport::Context
  class CsvSimulateContext < SimulateContext

    def initialize path
      super
    end

    def load_relate
      doc = Nokogiri::XML(open(CONFIG_FILE))
      doc.search(@function).each do |relate|
        @cell_info = get_content relate, "cell_info"
        @csv_file = get_content relate, "csv_file"

        @config_map = {}
        relate.search("threshold").each do |threshold|
          threshold_name = threshold.get_attribute("name")
          threshold_value = threshold.get_attribute("value")
          @config_map[threshold_name] = threshold_value
        end
      end
      @cell_infos = SpanReport::Simulate::CellInfos.new
      @cell_infos.load_from_xls @cell_info
    end

    def lgl_to_csv
      @is_temp = true
      @csv_file
    end

  end
end