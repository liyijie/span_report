# encoding: utf-8

module SpanReport
  module Lglconvert
    BEGIN_INDEX = 3;
    autoload :SignalProcess, "span_report/lglconvert/signal_process"
    autoload :EventProcess, "span_report/lglconvert/event_process"
  end
end