# encoding: utf-8

module SpanReport::Model
  class KpiItem
    attr_accessor :name, :desc, :kpi_eval

    ##################################
    #excel配置文件中共有3列，分别是：
    #1.名称
    #2.描述
    #3.计算公式
    ###################################
    def initialize(config_datas=[])
      @name = config_datas[0]
      @desc = config_datas[1]
      @kpi_eval = config_datas[2]
    end

    def eval_value! kpi_caches
      SpanReport.logger.debug "kpi_eval is:#{@kpi_eval}"
      return if @kpi_eval.nil? || @kpi_eval.empty?
      eval_string = @kpi_eval
      eval_string = eval_string.gsub(/<[\w\[\]]*>/) do |match|
        match = match.sub '<', ''
        match = match.sub '>', ''
        SpanReport.logger.debug "match is:#{match}"
        reportvalue = kpi_caches[match]
        if reportvalue
          match = reportvalue.getvalue
        else
          match = ""
        end
        SpanReport.logger.debug "match value is:#{match}"
        match ||= ""
      end
      begin
        value = eval eval_string
      rescue Exception => e
        value = ""
      end
      SpanReport.logger.debug "eval_string is:#{eval_string}"
      SpanReport.logger.debug "eval value is:#{value}"
      
      kpi_value = SpanReport::Process::Value.create ""
      kpi_value.add_value value
      kpi_caches[@name] = kpi_value
      SpanReport.logger.debug "add value is:#{kpi_value.getvalue}"
      SpanReport.logger.debug "kpi caches:#{@name}-#{kpi_caches[@name].getvalue}"
    end

    def to_s
      "kpi item: '#{@name}'-'#{@desc}'-'#{@kpi_eval}'"
    end
  end
end