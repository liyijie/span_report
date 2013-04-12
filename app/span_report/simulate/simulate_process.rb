#encoding: utf-8

module SpanReport::Simulate

  class SimulateProcess < SpanReport::Process::Base
    def initialize config_map, filter_map={}
      super()
      @config_map = config_map
      @filter_map = filter_map
    end

    # def process_data logdata, file_group=""
    #   contents = logdata.split(/,|:/)
    #   group_id = contents[1].to_i
    #   needed_ies = get_needed_ies group_id
    #   time = contents[2]
    #   ue = contents[0]
    #   data_map = {}

    #   needed_ies.each do |logitem|
    #     ie_name = logitem.name
    #     ie_index = logitem.index + 3
    #     if contents[ie_index] && !contents[ie_index].empty? && contents[ie_index] != "-999"
    #       data_map[@alis_map[ie_name]] = contents[ie_index]
    #     end
    #   end

    #   @ana_data.add_logdata_map time, ue, data_map
    # end

    def process_csv_data data_map
      ue = data_map["ue"]
      time = data_map["time"]

      pointdata = SpanReport::Simulate::PointData.new(time, ue, data_map)
      pointdata.expand_data

      point_data.filter_distance @config_map, @filter_map
      point_data.sort_cells
      point_data.fill_kpi_data @config_map


    end

    ###################################################
    # 根据过滤条件过滤点（模拟调整，这里的调整过程是叠加的）PointData
    # 主服务小区和邻小区排序 PointData
    # 计算每个点的KPI       PointData
    ###################################################
    def process_pointdata point_data
      point_data.filter_distance @config_map, @filter_map
      point_data.sort_cells
      point_data.fill_kpi_data @config_map
    end

  end
  
end