# encoding: utf-8

module SpanReport::Context

  class EventExportContext < BaseContext
    
    # 1. load map csv file
    # 2. read event file, loop every event data
    # 3. find relate information needed
    # 4. export the result to csv
    def process
      map_cache = load_map_csv

      event_ex = [:dblat, :dblon, :g624, :g627, :i637, :i642]
      output_events = []
      event_file = File.join @input_log, "event"
      EventCsv.foreach(event_file) do |event|
        pctime = event[:pctime]
        ueid = event[:ueid]

        event_ex.each do |ex|
          key = ex.to_s.sub('g', 'i').to_sym
          extra_info = map_cache.find(ueid, pctime, ex)
          event[key] = extra_info[ex] if extra_info
        end
        output_events << event
      end
      
      header = []
      header.concat EventCsv.header
      header.concat event_ex.map { |ex| ex.to_s.sub('g', 'i').to_sym }

      output_file = File.join @output_log, "event_ex.csv"
      CSV.open(output_file, 'w') do |f|
        f << header
        output_events.each do |event|
          f << header.map { |h| event[h] }
        end
      end
    end

    private

    def load_map_csv
      map_cache = MapCsv::MapCache.instance
      map_csv_file = File.join @input_log, "map.csv"
      map_cache.load_csv map_csv_file
      map_cache
    end
    
  end
  
end