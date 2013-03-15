# encoding: utf-8

module SpanReport::Context
  class SimulateContext < BaseContext
    def load_relate
      doc = Nokogiri::XML(open(CONFIG_FILE))
      doc.search(@function).each do |relate|
        @cell_info = get_content relate, "cell_info"
      end
    end

    def process
      SpanReport::Model::Logformat.instance.load_xml "config/LogFormat_100.xml"
      cell_infos = SpanReport::Simulate::CellInfos.new
      puts "cellconfig file is #{@cell_info}"
      cell_infos.load_from_xls @cell_info

      simulate_process = SpanReport::Simulate::SimulateProcess.new
      simulate_process.reg_needed_ies
      simulate_process.set_cellinfos cell_infos

      logfiles = SpanReport.list_files(@input_log, ["lgl"])
      begin
        filereader = SpanReport::Logfile::FileReader.new logfiles
        filereader.parse(simulate_process)

        simulate_process.to_file
      rescue Exception => e
        puts e
      ensure
        filereader.clear_files
      end
    end
  end
  
end