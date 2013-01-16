# encoding: utf-8

module SpanReport::Process
  
  class Export

    def initialize
      @reg_ies = Set.new
      @reg_groups = {}
    end

    def reg_iename iename
      @reg_ies << iename
      logitem = SpanReport::Model::Logformat.instance.get_logitem(iename)
      if logitem
        @reg_groups[logitem.group] ||= Set.new
        @reg_groups[logitem.group] << logitem
      end
    end

    def data_needed? logdata
      group_id = logdata.split(',', 3)[1].to_i
      @reg_groups.has_key? group_id
    end




  end
end