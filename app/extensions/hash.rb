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
  
  # By default, only instances of Hash itself are extractable.
  # Subclasses of Hash may implement this method and return
  # true to declare themselves as extractable. If a Hash
  # is extractable, Array#extract_options! pops it from
  # the Array when it is the last element of the Array.
  def extractable_options?
    instance_of?(Hash)
  end
end