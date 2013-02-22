# encoding: utf-8

require 'pathname'
require_relative "app/span_report"

path = Dir.getwd
puts "working path is: #{path}"

context = SpanReport::Context.create path

puts "process function is:#{context.function}"

context.process
