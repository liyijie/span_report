# encoding: utf-8

module SpanReport::Context
  class LglconvertContext < BaseContext

    def load_relate

    end

    def process

      SpanReport::Model::Logformat.instance.load_xml "config/LogFormat_100.xml"

      logfiles = SpanReport.list_files(@input_log, ["lgl"])
      logfiles.each do |logfile|
        begin
          filereader = SpanReport::Logfile::FileReader.new [logfile]
          signal_process = SpanReport::Lglconvert::SignalProcess.new
          event_process = SpanReport::Lglconvert::EventProcess.new

          processors = []
          processors << signal_process
          processors << event_process

          filereader.parse_many(processors)

          puts "logfile.filename is:#{logfile.filename}"
          # resultfile = logfile.filename.split(/\\|\//)[-1]
          # resultfile = resultfile.sub('lgl', 'report.xlsx')
          # resultfile = File.join @output_log, resultfile
          # SpanReport.logger.debug "resultfile is: #{resultfile}"
          signal_process.flush
          event_process.flush
        rescue Exception => e
          puts e
        ensure
          filereader.clear_files
        end
      end
      
    end
    
  end
  
end