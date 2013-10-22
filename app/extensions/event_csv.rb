# encoding: utf-8

require "smarter_csv"

# ueid,pctime,record_id,ue_version,ue_mode,rec_type,event,ExtraInfo

class EventCsv
  
  def self.foreach(input, options={}, &block)
    event_infos = []

    SmarterCSV.process(input, file_encoding: 'gbk', col_sep: /,|:/) do |events|
      event = events.first
      next if event[:event].to_s.empty?

      if block_given?
        yield event
      else
        event_infos << event
      end
    end

    event_infos
  end

  def self.output(outfile, output_events)
    header = self.header
    File.open(outfile, 'w') do |f|
      f.puts header.join(',')
      output_events.each do |event|
        csv_line = (header.map { |h| event[h]}).join(',')
        # should be covert the second ","" to ":""
        count = 0
        csv_line.gsub!(/,/) do |s|
          count += 1
          count == 2 ? ":" : s
        end
        f.puts csv_line
      end
    end
  end

  def self.header
    [:ueid, :pctime, :record_id, :ue_version, :ue_mode, :rec_type, :event, :extrainfo] 
  end
end