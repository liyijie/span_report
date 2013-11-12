# encoding: utf-8

require "smarter_csv"

# ueid,pctime,record_id,ue_version,ue_mode,rec_type,event,ExtraInfo

class EventCsv
  
  def self.foreach(input, options={}, &block)
    event_infos = []

    line_count = 0
    header = []
    File.open(input, "r:gbk") do |f|
      while ! f.eof?
        line = f.readline
        line.chomp!
        line_count += 1
        if line_count == 1
          header = line.split(',')
          header.map! { |e| e.to_s.strip.gsub(/\s+/,'_')}
          header.map! { |e| e.downcase.to_sym }
        else
          line.sub!(':', ',')
          content = line.split(',')
          event = Hash.zip(header, content)
          next if event.empty?
          if block_given?
            yield event
          else
            event_infos << event
          end
        end
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
        f.puts csv_line.encode('gbk')
      end
    end
  end

  def self.header
    [:ueid, :pctime, :record_id, :ue_version, :ue_mode, :rec_type, :event, :extrainfo] 
  end
end