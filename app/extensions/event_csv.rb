# encoding: utf-8

require "smarter_csv"

class EventCsv
  
  def self.foreach(input, options={}, &block)
    event_infos = []

    SmarterCSV.process(input, file_encoding: 'gbk', col_sep: /,|:/) do |events|
      event = events.first
      next if event[:event].to_s.empty?
      event_info = {} 
      event_info[:ueid] = event[:ueid]
      event_info[:pctime] = event[:pctime] 
      event_info[:time] = Time.at_pctime(event[:pctime])
      event_info[:event] = event[:event]
      event_info[:extrainfo] = event[:extrainfo]
      yield event_info if block_given?
    end
    
  end

  def self.header
    [:ueid, :pctime, :time, :event, :extrainfo]
  end
end