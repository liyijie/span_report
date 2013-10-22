# encoding: utf-8

require "smart_csv"

# ueid,pctime,record_id,ue_version,ue_mode,rec_type,signals,direction,timestamp,
# uu_groupname,hex_str

class SignalCsv

  def self.foreach(input, options={}, &block)
    signal_infos = []

    SmarterCSV.process(input, file_encoding: 'gbk', col_sep: /,|:/) do |signals|
      signal = signals.first
      next if signal[signals].to_s.empty?

      if block_given?
        yield signal
      else
        signal_infos << signal
      end
    end

    signal_infos
  end

end