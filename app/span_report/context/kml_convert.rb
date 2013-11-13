# encoding: utf-8

module SpanReport::Context
  class KmlConvertContext < BaseContext
    def load_relate
      doc = Nokogiri::XML(open(CONFIG_FILE))
      doc.search(@function).each do |relate|
        @ieconfig_file = get_content relate, "ieconfig"
        @interval = get_content relate, "interval"
        @cell_info = get_content relate, "cell_info"
      end
    end

    def process

      unzip_temp_dir = File.join @output_log, "temp"
      FileUtils.rm_rf unzip_temp_dir if File.exist?(unzip_temp_dir)
      Dir.mkdir(unzip_temp_dir)

      @ieconfig = SpanReport::Model::Ieconfig.instance.init @ieconfig_file

      logfiles = SpanReport.list_files(@input_log, ["lgl"])
      logfiles.each_with_index do |logfile, file_index|
        zip_file = logfile.filename
        dest_dir = unzip zip_file, unzip_temp_dir
        mapcsv_file = File.join dest_dir, "map.csv.list"
        kml_file = zip_file.sub("lgl", "kml")
        puts "converting #{zip_file} to #{kml_file} ..."

        convert_kml mapcsv_file, kml_file

        # 删除
        FileUtils.rm_rf dest_dir
      end
    end

    def convert_kml mapcsv_file, kml_file
      kml_cache = KmlCache.new kml_file, @interval, @cell_info
      MapCsv.foreach(mapcsv_file) do |row|
        kml_cache.add_data row
      end
      kml_cache.to_xml_file
    end
    
    #解压文件到临时目录中，为每个日志都解压到当前的文件夹中
    #返回解压后的目录
    def unzip zip_file, dest_dir
      Dir.mkdir(dest_dir) unless File.exist?(dest_dir)

      Zip::ZipFile.open zip_file do |zf|
        zf.each do |e|
          filename = e.name
          unless ["signal", "event", "map.csv", "IndoorPointmap"].index filename
            path = File.join dest_dir,"#{e.name}.txt" 
          else
            path = File.join dest_dir,"#{e.name}.list" 
          end
          zf.extract(e, path) { true } 
        end  
      end
      dest_dir
    end
    
  end

  class KmlCache
    include Geo
    PCI_KEY = :g624
    FREQ_KEY = :g627

    def initialize kml_path_file, interval, cell_file
      @kml_path = File.dirname kml_path_file
      @kml_file = File.basename kml_path_file
      @interval = interval.to_i
      @ie_nodes = {}

      # cache store lat, lon, pci, freq
      @context_cache = {}

      # read cell info file
      @cell_map = {}
      CellCsv.foreach(cell_file) do |cell_info|
        @cell_map[[cell_info[:pci], cell_info[:frequency_dl]]] ||= []
        @cell_map[[cell_info[:pci], cell_info[:frequency_dl]]] << cell_info
      end
    end

    # data is from MapCsv, the data is a hash
    # 1. get each ie data, start with "i"
    # 2. add the data to the ienodes
    def add_data data
      options = data.clone
      options.delete_if do |k, v|
        k.to_s.start_with? "i"
      end
      options[:time_interval] = @interval

      # fill cell_name and distance information
      dis_value = calc_distance data
      cell = relate_cell
      if dis_value && cell
        options[:distance] = dis_value
        options[:cell_name] = cell[:cellname]
      end

      data.each do |k, v|
        if k.to_s.start_with? "i"
          @ie_nodes[k] ||= IENode.new k
          ienode = @ie_nodes[k]
          ienode.add(v, options)
        end
      end
    end

    def to_xml_file
      builder = Nokogiri::XML::Builder.new(encoding: 'utf-8') do |xml|
        xml.kml(xmlns: "http://www.opengis.net/kml/2.2") {
          xml.Document {
            xml.name @kml_file
            @ie_nodes.each do |iename, ienode|
              ienode.to_xml xml
            end
          }
        }
      end

      output_file = File.join @kml_path, @kml_file
      File.open(output_file, "w") { |file| file.puts builder.to_xml }
    end

    private

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

  class IENode
    def initialize(name)
      @name = name
      @datas = {}
      @segment_nodes = {}
      @alias_name, segment_heads = get_segment_heads
      segment_heads.each_with_index do |head, index|
        @segment_nodes[index] = SegmentNode.new @name, head
      end
    end

    def to_xml xml
      xml.Folder{
        xml.name @alias_name
        @segment_nodes.each do |index, segment_node|
          segment_node.to_xml xml, index
        end
      }
    end

    # find the valid segment and add to it
    def add value, options
      @segment_nodes.each do |index, segment_node|
        break if segment_node.add_value value, options
      end
    end

    def get_segment_heads
      ieconfig = SpanReport::Model::Ieconfig.instance
      ieconfig.get_segments @name
    end
    
  end

  class SegmentNode
    def initialize(iename, head)
      @iename, @max, @min, @color = iename, head[:max], head[:min], head[:color]
      @last_time = 0
      @datas = []
    end

    def to_xml xml, index
      xml.Document { #section
        xml.name "[#{@min}, #{@max})"
        icon_style_id = "#{@iename}_#{index}"
        # icon style
        icon_hrefs = []
        icon_hrefs << "http://maps.google.com/mapfiles/kml/paddle/wht-blank_maps.png"
        icon_hrefs << "http://maps.google.com/mapfiles/kml/paddle/wht-stars_maps.png"
        2.times do |i|
          xml.Style(id: "#{icon_style_id}_#{i}") {
            xml.IconStyle {
              xml.color @color
              xml.colorMode "normal"
              xml.Icon {
                xml.href icon_hrefs[i]
              }
            }
          }
        end
        xml.StyleMap(id: icon_style_id) {
          xml.Pair {
            xml.key "normal"
            xml.styleUrl "##{icon_style_id}_0"
          }
          xml.Pair {
            xml.key "highlight"
            xml.styleUrl "##{icon_style_id}_1"
          }
        }

        # placemarks
        @datas.each do |data|
          xml.Placemark {
            xml.name data[:value]
            xml.styleUrl "##{icon_style_id}"
            xml.description "cell name:#{data[:cell_name]}\ndistance:#{data[:distance]}"
            xml.Point {
              xml.coordinates "#{data[:dblon]},#{data[:dblat]}"
            }
          }
        end
      } 
    end

    def valid? value
      value >= @min && value < @max
    end

    def add_value value, options
      valid = valid? value
      interval = options[:time_interval]
      if valid
        pctime = options[:pctime]
        if (pctime - @last_time > 1000 * interval)
          @last_time = pctime
          options[:value] = value
          @datas << options
        end
      end
      valid
    end
  end
end