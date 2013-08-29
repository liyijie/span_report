# encoding: utf-8

module SpanReport::Context
  class ReportContext < BaseContext

    def load_relate
      doc = Nokogiri::XML(open(CONFIG_FILE))
      doc.search(@function).each do |relate|
        @counter_def = get_content relate, "counter_def"
        @outer_def = get_content relate, "outer_def"
        @combine = get_content relate, "combine"
      end
    end

    def process

      SpanReport::Model::Logformat.instance.load_xml "config/LogFormat_100.xml"

      excel_export = SpanReport::Process::ReportExport.new @outer_def

      report = SpanReport::Process::Report.new

      counter_model = SpanReport::Model::CounterModel.new
      counter_model.parse @counter_def
      #counter配置
      counter_model.counter_items.each do |counter_item|
        report.reg_counter_item counter_item
      end
      #kpi配置
      counter_model.kpi_items.each do |kpi_item|
        report.reg_kpi_item kpi_item
      end

      logfiles = SpanReport.list_files(@input_log, ["lgl"])
      #多个日志合并导出
      if @combine == "true"
        begin
          filereader = SpanReport::Logfile::FileReader.new logfiles
          filereader.parse(report)
          report.count_kpi_value
          resultfile = File.join @output_log, "combine.report.xlsx"
          excel_export.to_excel resultfile, report

          report.clear
        rescue Exception => e
          puts e
        ensure
          filereader.clear_files
        end
      # 日志分别导出
      else
        logfiles.each do |logfile|
          begin
            filereader = SpanReport::Logfile::FileReader.new [logfile]
            filereader.parse(report)
            report.count_kpi_value
            puts "logfile.filename is:#{logfile.filename}"
            resultfile = logfile.filename.split(/\\|\//)[-1]
            resultfile = resultfile.sub('lgl', 'report.xlsx')
            resultfile = File.join @output_log, resultfile
            SpanReport.logger.debug "resultfile is: #{resultfile}"

            excel_export.to_excel resultfile, report
            
            report.clear
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