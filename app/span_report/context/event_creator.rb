# encoding: utf-8

module SpanReport::Context
  class EventCreator < BaseContext

    # def load_relate
      
    # end

    # * create the rules
    # * sort the rules, ie or singal
    # * read the orign events from event file
    # * if has any signal rule, read signal datas and process
    # * if has any ie rule, read map csv file datas and process
    # * insert the created event into the orgin signals
    # * rewrite the event file
    def process
      # * create the rules
      signal_rule = SignalRule.new signal_name: "RRCConnectionReconfiguration",
                                    event_name: "RRC Reconfig"
      ie_rule = IEDurationRule.new iename: "i637", event_name: "RSRP low", duration: 3,
                                  threshold: -100, compare_type: 1
      # * sort the rules, ie or singal
      # * read the orign events from event file
      event_file = File.join @input_log, "event"
      events = EventCsv.foreach(event_file)

      # * if has any signal rule, read signal datas and process
      signal_file = File.join @input_log, "signal"
      SignalCsv.foreach(signal_file) do |signal|
        if signal_rule.valid? signal
          event_added = signal_rule.create_event signal
          merge_event events, event_added
        end
      end
      # * if has any ie rule, read map csv file datas and process
      map_csv_file = File.join @input_log, "map.csv"
      MapCsv.foreach(map_csv_file) do |data|
        if ie_rule.valid? data
          event_added = ie_rule.create_event data
          merge_event events, event_added
        end
      end
      # * insert the created event into the orgin signals
      new_event_file = File.join @output_log, "event.new"
      # * rewrite the event file
      EventCsv.output(new_event_file, events)
    end

    def merge_event events, event_added
      insert_index = events.index {|event| event[:pctime] > event_added[:pctime]}
      insert_index.nil? ? events << event_added : events.insert(insert_index, event_added)
    end
  end

  # signal name equal, create the event which name is specify
  class SignalRule
    def initialize(*args)
      options = args.extract_options!
      @signal_name = options[:signal_name]
      @event_name = options[:event_name]
    end

    def valid? signal
      signal_name = signal[:signals]
      signal_name == @signal_name
    end

    def create_event signal
      event = {}
      # ueid,pctime,record_id,ue_version,ue_mode,rec_type from signal
      event[:ueid] = signal[:ueid]
      event[:pctime] = signal[:pctime]
      event[:record_id] = signal[:record_id]
      event[:ue_version] = signal[:ue_version]
      event[:ue_mode] = signal[:ue_mode]
      event[:rec_type] = signal[:rec_type]
      event[:event] = @event_name
      event[:extrainfo] = @signal_name

      event
    end
  end

  class IEDurationRule
    def initialize(*args)
      options = args.extract_options!
      @iename = options[:iename].to_sym
      @event_name = options[:event_name]
      @duration = options[:duration].to_i
      @threshold = options[:threshold].to_f
      # compare_type: 0(==) 1(<) 2(<=) 3(>) 4(>=)
      @compare_type = options[:compare_type].to_i

      @first_satify_time = 0
      @satisfied = false
    end

    # ieinfo is a hash: {ueid: "1", i625: -90,  pctime: "1231234"}
    # valid condition is as list:
    # * iename is equal
    # * threshold condition is satisfy
    # * duration time is satisfy
    def valid? ieinfo
      return false unless ieinfo.has_key? @iename
      check = ( value_valid?(ieinfo[@iename].to_f) )
      if check && !@satisfied
        @first_satify_time > 0 || @first_satify_time = ieinfo[:pctime].to_i
        return @satisfied = (ieinfo[:pctime].to_i - @first_satify_time > @threshold)
      elsif !check
        @first_satify_time = 0
        return @satisfied = false
      else
        return false
      end
    end

    def create_event ieinfo
      # ueid,pctime,record_id,ue_version,ue_mode,rec_type from signal
      event = {}
      event[:ueid] = ieinfo[:ueid]
      event[:pctime] = ieinfo[:pctime]
      event[:record_id] = 999
      event[:ue_version] = 20
      event[:ue_mode] = 6
      event[:rec_type] = 1
      event[:event] = @event_name
      event[:extrainfo] = @signal_name
      event
    end

    private
    def value_valid? ievalue
      result = false
      case @compare_type
      when 0
        result = ievalue == @threshold
      when 1
        result = ievalue < @threshold
      when 2
        result = ievalue <= @threshold
      when 3
        result = ievalue > @threshold
      when 4
        result = ievalue >= @threshold
      end
    end
    
  end
end