#encoding: utf-8

module SpanReport::Lglconvert

  class EventProcess < SpanReport::Lglconvert::SignalProcess

    def initialize
      super
      @datacaches = []
      @tempdata = []
      reg_needed_ies
    end

    def reg_needed_ies
      reg_iename "UEVersion", "UEVersion" 
      reg_iename "Event", "Event" 
      @file = File.new("event", "w")
    end

    def covert_data tempdata
      event = Event.new
      @tempdata.each do |linedata|
        contents = linedata.split(/,|:/)
        ueid = contents[0].to_i
        group_id = contents[1].to_i
        pctime = contents[2]

        event.ueid = ueid
        event.pctime = pctime

        if group_id == 100
          event.record_id = contents[BEGIN_INDEX + 0]
          event.ue_version = contents[BEGIN_INDEX + 1]
          event.ue_mode = contents[BEGIN_INDEX + 2]
          event.rec_type = contents[BEGIN_INDEX + 3]
        elsif group_id == 102
         event.event = contents[BEGIN_INDEX + 0]
       end
     end
     event
   end
 end
 
 class Event
   attr_accessor :ueid, :pctime, :record_id, :ue_version, :ue_mode, :rec_type, :event

   def to_s
     display = "#{ueid},#{pctime}:#{record_id},#{ue_version},#{ue_mode},#{rec_type},#{event}"
   end

   def valid?
     !event.nil?
   end
 end
end