#encoding: utf-8

module SpanReport::Simulate

  class ConvertFileProcess < SpanReport::Process::Base
    def initialize
      super
      @ana_data = AnaData.new
      reg_needed_ies
    end

    def process_data logdata, file_group=""
      contents = logdata.split(/,|:/)
      group_id = contents[1].to_i
      needed_ies = get_needed_ies group_id
      time = contents[2]
      ue = contents[0]
      data_map = {}

      needed_ies.each do |logitem|
        ie_name = logitem.name
        ie_index = logitem.index + 3
        if contents[ie_index] && !contents[ie_index].empty? && contents[ie_index] != "-999"
          data_map[@alis_map[ie_name]] = contents[ie_index]
        end
      end

      @ana_data.add_logdata_map time, ue, data_map
    end

    def set_cellinfos cell_infos
      @ana_data.cell_infos = cell_infos
    end

    def to_file resultfile 
      @ana_data.to_file resultfile
    end

    def reg_needed_ies
      reg_iemap = @ana_data.get_reg_iemap
      reg_iemap.each do |iename, aliasname|
        reg_iename iename, aliasname
      end
    end

  end
  
end