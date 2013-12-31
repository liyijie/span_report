# encoding: utf-8

module SpanReport::Process::Value
  class Time < Avg

    def initialize mode
      super()
      params = mode.split(/\(|\)|,/)
      @begin = params[1].to_s
      @end = params[2].to_s
      @begin_time = 0
      @end_time = 0
    end

    def add_value ievalue, pctime=0, gps=nil
      unless (ievalue.nil? || ievalue == "")
        if @begin == ievalue
          @begin_time = pctime
        elsif ( @end == ievalue && @begin_time > 0)
          @end_time = pctime
          delay_time = @end_time - @begin_time if (@end_time > @begin_time && @begin_time > 0)
          @begin_time = 0
          process delay_time
        end
      end
    end
      
  end

end