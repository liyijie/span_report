require "csv"

module MapCsv
  def self.foreach(input, options={}, &block)
    default_options = {
      type_col: 0, pctime_col: 1, data_start_col: 7
    }
    options = default_options.merge(options)
    header_map = {}
    begin
      CSV.foreach(input) do |row|
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
end

