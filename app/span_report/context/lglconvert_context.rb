# encoding: utf-8
require 'fileutils'  
require 'zip/zip'  
require 'zip/zipfilesystem' 

module SpanReport::Context
  class LglconvertContext < BaseContext

    def load_relate
      doc = Nokogiri::XML(open(CONFIG_FILE))
      doc.search(@function).each do |relate|
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

      logfiles = SpanReport.list_files(@input_log, ["lgl"])
      logfiles.each do |logfile|
        begin
          logfile_name = logfile.filename.split(/\\|\//)[-1]

          tempfile_path = "./config/#{logfile_name}"
          filereader = SpanReport::Logfile::FileReader.new [logfile]
          #信令事件导出
          signal_process = SpanReport::Lglconvert::SignalProcess.new
          signal_process.open_file tempfile_path
          event_process = SpanReport::Lglconvert::EventProcess.new
          event_process.open_file tempfile_path

          # 地图日志导出
          export = SpanReport::Process::Export.new
          @ieconfigs.each do |ie_name, ie_alias|
            export.reg_iename ie_name, ie_alias
          end
          resultfile = File.join tempfile_path, "map.csv"
          export.config_export_file resultfile

          processors = []
          processors << signal_process
          processors << event_process
          processors << export

          filereader.parse_many(processors)

          signal_process.flush
          event_process.flush
          export.write_result
          export.clear
          signal_process.close_file
          event_process.close_file
          export.close_file

          # zip new lgl
          new_lglfile_name = logfile_name.sub ".lgl", ".new.lgl"
          zipfile = "#{@output_log}/#{new_lglfile_name}"
          zip tempfile_path, zipfile
          
        rescue Exception => e
          puts e
        ensure
          filereader.clear_files
        end
      end
      
    end

    def zip source_path, zipfile
      FileUtils.rm zipfile if File.exist? zipfile
      Zip::ZipFile.open(zipfile,Zip::ZipFile::CREATE) do |zipfile|
        # 给压缩文件中添加文件
        # 第一个参数 被添加文件在压缩文件中显示的路径
        # 第二个参数 被添加文件的源路径
        SpanReport.list_files(source_path, ["txt", "csv"]).each do |iefile|
          file_name = iefile.filename.split(/\\|\//)[-1]
          file_name = file_name.sub ".txt", ""
          source_file = iefile.filename
          zipfile.add file_name, source_file
        end
       
      end
    end
    
  end
  
end