# encoding: utf-8

module SpanReport::Process::Value
  class Distance < Sum

    def initialize mode
      super()
      @value = 0.0
      
      @last_gps = nil
      @last_pctime = 0
    end

    def add_value ievalue, pctime=0, gps=nil
      return if (ievalue.nil? || ievalue == "" || gps.nil?)
      if ((pctime-@last_pctime).abs < 20000)
        if @last_gps
          dis = @last_gps.distance gps
          process dis if dis < 1000
        end
      end
      @last_gps = gps
      @last_pctime = pctime
    end

    def add_invalid_value ievalue, pctime=0, gps=nil
      return if (ievalue.nil? || ievalue == "" || gps.nil?)
      if ((pctime-@last_pctime).abs < 20000)
        if @last_gps
          dis = @last_gps.distance gps
          process dis if dis < 1000
        end
      end
      @last_gps = nil
      @last_pctime = pctime
    end

  end

end