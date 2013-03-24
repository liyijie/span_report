# encoding: utf-8

module SpanReport::Map

  class CellMapProcess < MapProcess

    attr_accessor :result_path, :cell_infos
     
    def initialize
      super
      @mapfile_map = {}
    end

    def flush
      @export_datas.each do |raw_pointdata|
        raw_pointdata.fill_extra @cell_infos
        cell_pointdatas = raw_pointdata.expand_celldatas
        cell_pointdatas.each do |pointdata|
          cell_name = pointdata.cell_name
          next if cell_name.nil? || cell_name.empty?
          unless @mapfile_map.has_key? cell_name
            result_filename = File.join @result_path, "#{cell_name.encode('utf-8')}.csv"
            puts "result_filename is:#{result_filename}"
            @mapfile_map[cell_name] = File.new(result_filename, "w")  
            @mapfile_map[cell_name].puts head_string
          end
          
          file = @mapfile_map[cell_name]

          mapdata = pointdata_to_mapdata pointdata
          file.puts mapdata
        end
      end
      @export_datas.clear
    end

  end
  
end
