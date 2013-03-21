#encoding: utf-8

module SpanReport::Lglconvert

  class SignalProcess < SpanReport::Process::Base

    def initialize
      super
      @datacaches = []
      @tempdata = []
      reg_needed_ies
    end

    def reg_needed_ies
      reg_iename "UEVersion", "UEVersion" 
      reg_iename "Signals", "Signals" 
      reg_iename "UuSignalId", "UuSignalId" 
      reg_iename "HEXstr", "HEXstr"
    end

    def open_file tempfile_path
      Dir.mkdir(tempfile_path) unless File.exist?(tempfile_path)
      @file = File.new("#{tempfile_path}/signal.txt", "w")
    end

    def process_data logdata, file_group=""
      contents = logdata.split(/,|:/)
      ueid = contents[0].to_i
      group_id = contents[1].to_i
      pctime = contents[2]

      if (group_id == 100)
        if @tempdata.size > 1
          data = covert_data(@tempdata)
          @datacaches << data if data.valid?
          write_result
        end
        @tempdata.clear
      end
      @tempdata << logdata
    end

    def covert_data tempdata
      signal = Signal.new
      @tempdata.each do |linedata|
        contents = linedata.split(/,|:/)
        ueid = contents[0].to_i
        group_id = contents[1].to_i
        pctime = contents[2]

        signal.ueid = ueid
        signal.pctime = pctime

        if group_id == 100
          signal.record_id = contents[BEGIN_INDEX + 0]
          signal.ue_version = contents[BEGIN_INDEX + 1]
          signal.ue_mode = contents[BEGIN_INDEX + 2]
          signal.rec_type = contents[BEGIN_INDEX + 3]
        elsif group_id == 103
          signal.signals = contents[BEGIN_INDEX + 0]
        elsif group_id == 105
          signal.direction = contents[BEGIN_INDEX + 3]
          signal.timestamp = contents[BEGIN_INDEX + 5]
          signal.uu_groupname = contents[BEGIN_INDEX + 4]
        elsif group_id == 151
         signal.hex_str = contents[BEGIN_INDEX + 0]
       end
     end
     signal
   end

   def write_result   
     if @datacaches.size > 100
       flush
     end
   end

   def flush
     @datacaches.each do |data|
       @file.puts data.to_s
     end
     @datacaches.clear
   end
 end
 
 class Signal
   attr_accessor :ueid, :pctime, :record_id, :ue_version, :ue_mode, :rec_type,:signals, :direction, :timestamp, :uu_groupname, :hex_str

   def to_s
     display = "#{ueid.to_s},#{pctime.to_s}:#{record_id.to_s},#{ue_version.to_s},#{ue_mode.to_s},#{rec_type.to_s},"
     display << "#{signals.to_s},#{direction.to_s},#{timestamp.to_s},#{uu_groupname.to_s},#{hex_str.to_s}"
   end

   def valid?
     !signals.nil?
   end
 end
end