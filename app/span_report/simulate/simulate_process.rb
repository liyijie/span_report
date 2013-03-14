#encoding: utf-8

module SpanReport::Simulate

  class SimulateProcess < SpanReport::Process::Base
    def initialize
      super
      @export_datas = []
      @ie_caches = {}
      @file = nil
      @ana_data = AnaData.new
    end

    def process_data logdata, file_group=""
      contents = logdata.split(/,|:/)
      group_id = contents[1].to_i
      needed_ies = get_needed_ies group_id

      needed_ies.each do |logitem|
        ie_name = logitem.name
        ie_index = logitem.index + 3
        if contents[ie_index] && !contents[ie_index].empty? && contents[ie_index] != "-999"
          @ie_caches[ie_name] = contents[ie_index]
        end
      end

    end

    def reg_needed_ies
      reg_iemap = @ana_data.get_reg_iemap
      reg_iemap.each do |iename, aliasname|
        reg_iename iename, aliasname
      end
    end

  end
  
end