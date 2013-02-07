# encoding: utf-8

require 'logger'

$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), "..", "app"))

require "nokogiri"

module SpanReport

  autoload :Condition, "span_report/condition"
  autoload :Model, "span_report/model"
  autoload :Logfile, "span_report/logfile"
  autoload :Process, "span_report/process"

  file = open('log.txt', File::WRONLY | File::CREAT)  
  @@logger = Logger.new(file)

  def self.logger
    @@logger
  end

end
