# encoding: utf-8

module SpanReport::Context
  class ExportContext < BaseContext

    def load_relate
      doc = Nokogiri::XML(open(CONFIG_FILE))
      doc.search(@function).each do |relate|
        @combine = get_content relate, "combine"
        @ieconfigs = {}
        relate.search("ieconfig").each do |ieconfig|
          filename = ieconfig.get_attribute("name")
          @ieconfigs[filename] = {}
          ieconfig.search("ie").each do |ie|
            ie_name = ie.get_attribute("name")
            ie_alias = ie.get_attribute("alias")
            @ieconfigs[filename][ie_name] = ie_alias
          end
        end
        @range_context = {}
        relate.search("range").each do |range|
          @range_context[:count_range] = range.get_attribute("count_range")
          @range_context[:begin_time] = range.get_attribute("begin_time")
          @range_context[:end_time] = range.get_attribute("end_time")
        end

      end
    end

    def process

      SpanReport::Model::Logformat.instance.load_xml "config/LogFormat_100.xml"

      @ieconfigs.each do |filename, iemap|
        export = SpanReport::Process::Export.new
        iemap.each do |ie_name, ie_alias|
          export.reg_iename ie_name, ie_alias
        end
        # add context to the export processor
        export.add_range @range_context

        logfiles = SpanReport.list_files(@input_log, ["lgl"])
        #多个日志合并导出
        if @combine == "true"
          begin
            resultfile = File.join @output_log, filename
            export.config_export_file resultfile
            filereader = SpanReport::Logfile::FileReader.new logfiles
            filereader.parse_many([export])

            export.close_file
          rescue Exception => e
            puts e
            puts e.backtrace
          ensure
            filereader.clear_files if filereader
          end
        # 日志分别导出
        else
          logfiles.each do |logfile|
            begin
              dest_dir = File.join @output_log, logfile.filename.split(/\\|\//)[-1].sub('.lgl', '')
              Dir.mkdir(dest_dir) unless File.exist?(dest_dir)

              resultfile = File.join dest_dir, filename
              export.config_export_file resultfile

              filereader = SpanReport::Logfile::FileReader.new [logfile]
              filereader.parse(export)
              
              SpanReport.logger.debug "resultfile is: #{resultfile}"

              export.close_file
            rescue Exception => e
              puts e
              puts e.backtrace
              next
            ensure
              filereader.clear_files if filereader
            end
          end
        end

      end
      
    end
    
  end
  
end