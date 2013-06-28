# encoding: utf-8

module SpanReport::Process::Value
  class DistanceCondition < Sum

    def initialize mode
      super()
      @value = 0.0

      params = mode.split(/\(|\)|,/)
      # IE小于该阈值为符合条件
      @low_threthold = params[1].to_f unless params[1].to_s.empty?
      @high_threthold = params[2].to_f unless params[2].to_s.empty?
      # 时间窗大小，秒换算成毫秒
      @time_interval = params[3].to_f * 1000
      # 占比大于该比例阈值，则计算距离
      @ratio_threthold = params[4].to_f
      
      reset
    end

    def add_value ievalue, pctime=0, gps=nil
      return if (ievalue.nil? || ievalue == "" || gps.nil?)

      if ((pctime-@last_pctime).abs < 20000)
        if @last_gps
          dis = @last_gps.distance gps
          @distance += dis if dis < 100
        end
      end

      if (pctime-@begin_pctime).abs > @time_interval #超过一个时间窗了
        # 计算结果
        ratio = @valid_count * 1.0 / @all_count
        process @distance if ratio > @ratio_threthold

        # 置标志位
        reset
        @begin_pctime = pctime
      else
        @valid_count += 1 if value_valid? ievalue.to_f
        @all_count += 1
      end

      @last_gps = gps
      @last_pctime = pctime
    end

    private

    def value_valid? ievalue
      if @low_threthold && @high_threthold
        ievalue > @low_threthold && ievalue < high_threthold
      elsif @low_threthold
        ievalue > @low_threthold
      elsif @high_threthold
        ievalue < @high_threthold
      end      
    end

    def reset
      @last_gps = nil
      @distance = 0.0
      @begin_pctime = 0
      @all_count = 0
      @valid_count = 0
      @last_pctime = 0
    end

  end

end