# encoding: utf-8

module SpanReport::Process
  class Base

    def initialize
      @reg_groups = {}
      @reg_ies = []
      @alis_map = {}
    end

    def reg_iename iename, alisname
      @reg_ies << iename
      @alis_map[iename] = alisname
      reg_log_group iename
    end

    def reg_log_group iename
      logitem = SpanReport::Model::Logformat.instance.get_logitem(iename)
      if logitem
        @reg_groups[logitem.group] ||= []
        @reg_groups[logitem.group] << logitem
      end
    end

    def get_needed_ies group_id
      needed_ies = @reg_groups[group_id]
    end

    ############################################
    #判断数据是否需要进行处理
    ############################################
    def data_needed? logdata
      group_id = group_id = logdata.split(',', 3)[1].to_i
      @reg_groups.has_key? group_id
    end

    ########################################
    #增加一条log数据
    #先判断这条数据是否是报表相关的，如果不是需要的，这条数据可以直接舍弃
    ########################################
    def add_logdata logdata
      process_data logdata if data_needed? logdata
    end

  end
end