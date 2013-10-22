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

  def self.output(outfile, output_events)
    header = self.header
    CSV.open(outfile, 'w') do |f|
      f << header
      output_events.each do |event|
        csv_line = f.generate_line(header.map { |h| event[h]})
        # should be covert the second ","" to ":""
        count = 0
        csv_line.gsub!(/,/) do |s|
          count += 1
          count == 2 ? ":" : s
        end
        f << csv_line
      end
    end
  end

  def self.header
    [:ueid, :pctime, :record_id, :ue_version, :ue_mode, :rec_type, :event, :extrainfo] 
  end
end