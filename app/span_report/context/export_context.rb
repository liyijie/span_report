# encoding: utf-8

module SpanReport::Context
  class ExportContext < BaseContext

    def load_relate
      doc = Nokogiri::XML(open(CONFIG_FILE))
      doc.search(@function).each do |relate|
        @combine = get_content relate, "combine"
        @ieconfigs = {}
        relate.search("ie").each do |ie|
          ie_name = ie.get_attribute("name")
          ie_alias = ie.get_attribute("alias")
          @ieconfigs[ie_name] = ie_alias
        end
      end
    end

    def process

      SpanReport::Model::Logformat.instance.load_xml "config/LogFormat_100.xml"

      export = SpanReport::Process::Export.new
      @ieconfigs.each do |ie_name, ie_alias|
        export.reg_iename ie_name, ie_alias
      end

      logfiles = SpanReport.list_files(@input_log, ["lgl"])
      #多个日志合并导出
      if @combine == "true"
        begin
          resultfile = File.join @output_log, "combine.export.csv"
          export.config_export_file resultfile
          filereader = SpanReport::Logfile::FileReader.new logfiles
          filereader.parse_many([export])

          # export.write_result(resultfile)
          export.clear
        rescue Exception => e
          puts e
        ensure
          filereader.clear_files
        end
      # 日志分别导出
      else
        logfiles.each do |logfile|
          begin
            resultfile = logfile.filename.split(/\\|\//)[-1]
            resultfile = resultfile.sub('lgl', 'export.csv')
            resultfile = File.join @output_log, resultfile
            export.config_export_file resultfile

            filereader = SpanReport::Logfile::FileReader.new [logfile]
            filereader.parse(export)
            
            SpanReport.logger.debug "resultfile is: #{resultfile}"

            export.write_result(resultfile)
            export.clear
          rescue Exception => e
            next
          ensure
            filereader.clear_files
          end
        end
      end
      
    end
    
  end
  
end