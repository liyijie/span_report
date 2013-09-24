# encoding: utf-8

module SpanReport::Context
  class KmlConvertContext < BaseContext
    def load_relate
      doc = Nokogiri::XML(open(CONFIG_FILE))
      doc.search(@function).each do |relate|
        @ieconfig_file = get_content relate, "ieconfig"
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
      kml_cache = KmlCache.new
      MapCsv.foreach(mapcsv_file) do |row|
        kml_cache.add_data row
      end
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
    def initialize
      @ie_nodes = {}
    end

    # data is from MapCsv, the data is a hash
    # 1. get each ie data, start with "i"
    # 2. add the data to the ienodes
    def add_data data
      options = data.clone
      options.delete_if do |k, v|
        k.to_s.start_with? "i"
      end
      data.each do |k, v|
        if k.to_s.start_with? "i"
          @ie_nodes[k] ||= IENode.new k
          ienode = @ie_nodes[k]
          ienode.add(v, options)
        end
      end
    end
    
  end

  class IENode
    def initialize(name)
      @name = name
      @datas = {}
      @segment_nodes = {}
      segment_heads = get_segment_heads
      segment_heads.each_with_index do |head, index|
        @segment_nodes[index] = SegmentNode.new @name, head
      end
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
    attr_accessor :color
    def initialize(iename, head)
      @iename, @max, @min, @color = iename, head[:max], head[:min], head[color]
      @datas = []
    end

    def valid? value
      value >= @min && value < @max
    end

    def add_value value, options
      valid = valid? value
      if valid
        options[:value] = value
        @datas << options
      end
      valid
    end
  end
end