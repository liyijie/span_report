class Hash
  def self.zip(keys,values) # from Facets of Ruby library
    h = {}
    keys.size.times{ |i| h[ keys[i] ] = values[i] }
    # delete the empty value
    h.delete_if{|k,v| v.nil? || v =~ /^\s*$/}
    # convert float and integer value
    h.each do |k,v|
      case v
      when /^[+-]?\d+\.\d+$/
        h[k] = v.to_f
      when /^[+-]?\d+$/
        h[k] = v.to_i
      end
    end
    h
  end
end