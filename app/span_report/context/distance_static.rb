# encoding: utf-8

module SpanReport::Context

  class DistanceStaticContext < BaseContext

    include Geo
    PCI_KEY = :g624
    FREQ_KEY = :g627

    def load_relate
      doc = Nokogiri::XML(open(CONFIG_FILE))
      doc.search(@function).each do |relate|
        @cell_info = get_content relate, "cell_info"
        @iename = get_content(relate, "iename").to_sym
      end
    end

    def process
      # cache store lat, lon, pci, freq
      @context_cache = {}
      cell_file = @cell_info
      map_csv_file = File.join @input_log, "map.csv"

      # read cell info file
      @cell_map = {}
      CellCsv.foreach(cell_file) do |cell_info|
        @cell_map[[cell_info[:pci], cell_info[:frequency_dl]]] ||= []
        @cell_map[[cell_info[:pci], cell_info[:frequency_dl]]] << cell_info
      end

      # read map.csv
      result_cache = {}
      result_file = File.join @output_log, "distance_static.csv"
      file = File.new(result_file, 'w')
      MapCsv.foreach(map_csv_file) do |data|
        dis_value = calc_distance data
        ie_value = data[@iename]
        cell = relate_cell
        if ie_value && dis_value && cell
          cell_name = cell[:cellname]
          add_value result_cache, "all", dis_value, ie_value
          add_value result_cache, cell_name, dis_value, ie_value
        end
      end

      result_cache.each do |cell_name, dis_map|
        result_string = "#{cell_name},"
        sort_dis_map = dis_map.sort_by do |dis_value, value|
          dis_value
        end
        sort_dis_map.each do |dis_value, value|
          avg = (value[:sum] / value[:count]).round(2)
          result_string << "#{dis_value}:#{avg};"
        end
        file.puts result_string.encode('gbk') if file
      end

      file.close if file
    end

    private

    def add_value result_cache, cell_name, dis_value, ie_value
      result_cache[cell_name] ||= {}
      result_cache[cell_name][dis_value] ||= {}
      result_cache[cell_name][dis_value][:count] ||= 0
      result_cache[cell_name][dis_value][:count] += 1

      result_cache[cell_name][dis_value][:sum] ||= 0.0
      result_cache[cell_name][dis_value][:sum] += ie_value
    end

    # caculate the distance from the point(context cache) to relate cell
    def calc_distance data
      # update the context cache
      @context_cache[:lat] = data[:dblat] if data[:dblat]
      @context_cache[:lon] = data[:dblon] if data[:dblon]
      @context_cache[:pci] = data[PCI_KEY] if data[PCI_KEY]
      @context_cache[:freq] = data[FREQ_KEY] if data[FREQ_KEY]

      cell = relate_cell
      return nil if cell.nil?
      recent_gps = [@context_cache[:lat], @context_cache[:lon]]
      cell_gps = [cell[:latitude], cell[:longitude]]
      distance(recent_gps, cell_gps)
    end

    # fecth the cell info from the context cache by [pci, freq]
    # if the cell info has more than one records, should find the nearest one
    def relate_cell
      relate = nil

      if [@context_cache[:pci], @context_cache[:freq]] == @last_key
        relate = @last_cell
      else
        @cell_map ||= {}
        cells = @cell_map[[@context_cache[:pci], @context_cache[:freq]]] || []
        recent_gps = [@context_cache[:lat], @context_cache[:lon]]
        sort_cells = cells.sort_by do |cell|
          cell_gps = [cell[:latitude], cell[:longitude]]
          distance(recent_gps, cell_gps)
        end
        relate = sort_cells.first
        @last_key = [@context_cache[:pci], @context_cache[:freq]]
        @last_cell = relate
      end
      relate
    end
  end
  
end