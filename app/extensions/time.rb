class Time
  def self.at_pctime pctime
    if pctime < 1000000000
      time = Time.new(2000,1,1) + pctime.to_f/1000
    else
      time = Time.at(pctime.to_f/1000)
    end
    time
  end

  def to_s
    "#{self.hour}:#{self.min}:#{format("%.3f", self.sec+self.subsec)}"
  end
end