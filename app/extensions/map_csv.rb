require "csv"
require "singleton"

module MapCsv
  # type: LTE or TD
  # pctime
  # ueid
  # dblon
  # dblat
  # g624/g85
  # g627/g86
  # i637..i945/i87..i283
  def self.foreach(input, options={}, &block)
    default_options = {
      type_col: 0, pctime_col: 1, data_start_col: 7
    }
    options = default_options.merge(options)
    header_map = {}
    begin
      CSV.foreach(input) do |row|
        row[options[:type_col]] || row[options[:type_col]] = "Time" # for old log has no type
        type = row[options[:type_col]]
        if row[options[:pctime_col]].to_i == 0
          header = []
          row.each_with_index do |e, index|
            if index < options[:data_start_col] && e.start_with?('i')
              e = e.sub("i", "g")
            end
            header << e
          end
          header[options[:type_col]] = "type"
          header.map! { |e| e.to_s.strip.gsub(/\s+/,'_')}
          header.map! { |e| e.downcase.to_sym }
          header_map[type] = header
          next
        else
          data = row
          type = data[options[:type_col]]
          next unless header_map.has_key? type
          header = header_map[type]
          hash = Hash.zip(header, data)
          next if hash.empty?
          if block_given?
            yield hash  # do something with the hash in the block (better to use chunking here)
          end
        end
      end
    rescue Exception => e
      puts e
      puts e.backtrace
    ensure
      return header_map
    end
  end


  # map cache, load datas from map.csv
  # can be find by time
  # select the data list by time range

  class MapCache
    include Singleton

    def load_csv csv_file
        # context, {ueid => {g624 => value, ...}}
        @context = {}
        @cache = []
        MapCsv.foreach(csv_file) do |data|
          item = data.select { |key, value| key =~ /^(db|g)/ }
          ueid = data[:ueid]
          @context[ueid] ||= {}
          @context[ueid].merge! item
          data.merge! @context[ueid]
          @cache << data
        end
      end

      def find ueid, pctime, iename
        @cache.find do |data|
          data[:ueid] == ueid && data[:pctime] >= pctime && data[iename]
        end
      end

      def select ueid, (begin_pctime, end_pctime)
        @cache.select do |data|
          data[:ueid] == ueid && data[:pctime] >= begin_pctime && data[:pctime] <= end_pctime 
        end
      end

    end

  end
