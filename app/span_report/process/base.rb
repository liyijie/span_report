# encoding: utf-8
require "set"

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

    def convert_time pctime
      time = Time.new(2000,1,1) + pctime.to_f/1000
      dis_time = "#{time.hour}:#{time.min}:#{format("%.3f", time.sec+time.subsec)}"
    end

    def reg_log_group iename
      logitem = SpanReport::Model::Logformat.instance.get_logitem(iename)
      if logitem
        @reg_groups[logitem.group] ||= Set.new
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
      group_id = logdata.split(',', 3)[1].to_i
      @reg_groups.has_key? group_id
    end

    ########################################
    #增加一条log数据，这里可以根据日志进行分组统计
    #先判断这条数据是否是报表相关的，如果不是需要的，这条数据可以直接舍弃
    ########################################
    def add_logdata logdata, file_group=""
      # begin
        before_process(logdata, file_group) if respond_to? :before_process
        process_data(logdata, file_group) if data_needed? logdata
      # rescue Exception => e
        # SpanReport.logger.debug "process data error:#{e}"
      # end
    end

  end
end