# encoding: utf-8

module SpanReport::Process::Value
  class Cdf < BaseValue

    def initialize mode
      super()
      params = mode.split(/\(|\)|,/)
      @min = params[1].to_f
      @max = params[2].to_f
      @step = params[3].to_f
      @count = 0
      init_cdfcounts

    end

    def process ievalue
      return if (ievalue.to_s.empty?)
      return if (ievalue.to_f > @max || ievalue.to_f < @min)
      @count += 1
      @cdfcounts.each do |cdfcount|
        cdfcount.process ievalue
      end
    end

    def getvalue params
      value = ""
      if params.size == 1   # cdf value
        index = params[0].to_i
        value = @cdfcounts[index].getvalue.to_f / @count if @count > 0
      elsif params.size == 2  # cdf threshold
        threshold = params[1].to_f
        count_threshold = threshold * @count
        @cdfcounts.each do |cdfcount|
          if cdfcount.getvalue >= count_threshold
            value = cdfcount.threthold
            break
          end
        end
      end
      value
    end

    private
    def init_cdfcounts
      @cdfcounts = []
      @min.step(@max, @step).each do |threthold|
        cdfcount = CdfCount.new threthold
        @cdfcounts << cdfcount
      end
    end
    
  end

  class CdfCount

    attr_reader :threthold

    def initialize threthold
      @threthold = threthold.to_f
      @count = 0
    end

    def valid? ievalue
      ievalue.to_f <= @threthold
    end

    def process ievalue
      @count += 1 if valid? ievalue
    end

    def getvalue
      @count
    end
    
  end
end