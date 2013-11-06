# encoding: utf-8

module SpanReport::Context
  
  class SignalExportContext < EventExportContext
    def self.header
      [:ueid, :pctime, :time, :signals, :ue_mode, :direction, :uu_groupname]
    end

    # 1. load map csv file
    # 2. read signal file, loop every signal data
    # 3. find relate information needed
    # 4. export the result to csv
    def process
      map_cache = load_map_csv
      signal_ex = [:dblat, :dblon, :g624, :g627, :i637, :i642]
      output_signals = []
      signal_file = File.join @input_log, "signal"
      SignalCsv.foreach(signal_file) do |signal|
        pctime = signal[:pctime]
        ueid = signal[:ueid]

        signal_ex.each do |ex|
          key = ex.to_s.sub('g', 'i').to_sym
          extra_info = map_cache.find(ueid, pctime, ex)
          signal[key] = extra_info[ex] if extra_info
        end
        output_signals << signal
      end

      header = []
      header.concat SignalExportContext.header
      header.concat signal_ex.map { |ex| ex.to_s.sub('g', 'i').to_sym }

      output_file = File.join @output_log, "signal_ex.csv"
      CSV.open(output_file, 'w') do |f|
        f << header
        output_signals.each do |signal|
          f << header.map { |h| signal[h] }
        end
      end
        
    end
  end
  
  
end