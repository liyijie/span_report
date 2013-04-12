# encoding: utf-8


module SpanReport::Simulate
  class CellKpiProcess

    attr_reader :cell_kpivalue_map, :disturb_details, :effectsinr_kpi, :overrange_kpi

    def initialize config_map
      weak_cover_threshold = config_map[TDL_WEAK_COVER_THRESHOLD].to_f
      disturb_threshold = config_map[DISTURB_THRESHOLD].to_f
      disturb_strength_threshold = config_map[DISTURB_STRENGTH_THRESHOLD].to_f
      over_range_count_threshold = config_map[OVERLAP_COVER_THRESHOLD].to_f
      ncell_valid_threshold = config_map[NCELL_VALID_THRESHOLD].to_f
      over_cover_ratio_threshold = config_map[OVER_COVER_RATIO_THRESHOLD].to_f
      high_disturb_threshold = config_map[HIGH_DISTURB_THRESHOLD].to_f

      @weakcover_ratio_kpi = WeakCoverRatioKpi.new weak_cover_threshold
      @overlapcover_ratio_kpi = OverLapCoverRatioKpi.new disturb_strength_threshold, over_range_count_threshold
      @ncell_disturb_ratio_kpi = NCellDisturbRatioKpi.new disturb_strength_threshold, over_range_count_threshold
      @disturb_ratio_kpi = DisturbRatioKpi.new disturb_threshold, ncell_valid_threshold, over_cover_ratio_threshold
      @high_disturb_ratio_kpi = HighDisturbRatioKpi.new high_disturb_threshold
      @effectsinr_kpi = EffectSinrKpi.new
      @overrange_kpi = OverRangeKpi.new

      @cell_kpivalue_map = {}
      @disturb_details = []
    end

    def process_pointdata pointdata
      @weakcover_ratio_kpi.static pointdata
      @overlapcover_ratio_kpi.static pointdata
      @ncell_disturb_ratio_kpi.static pointdata
      @disturb_ratio_kpi.static pointdata
      @high_disturb_ratio_kpi.static pointdata
      @effectsinr_kpi.static pointdata
      @overrange_kpi.static pointdata
    end

    def cal_kpi_value
      @weakcover_ratio_kpi.each do |cell_name, kpivalue|
        @cell_kpivalue_map[cell_name] ||= CellKpiValue.new cell_name
        @cell_kpivalue_map[cell_name].weakcover_ratio_kpi = kpivalue.ratio
      end

      @overlapcover_ratio_kpi.each do |cell_name, kpivalue|
        @cell_kpivalue_map[cell_name] ||= CellKpiValue.new cell_name
        @cell_kpivalue_map[cell_name].overlapcover_ratio_kpi = kpivalue.ratio
      end

      @ncell_disturb_ratio_kpi.each do |cell_name, kpivalue|
        @cell_kpivalue_map[cell_name] ||= CellKpiValue.new cell_name
        @cell_kpivalue_map[cell_name].ncell_disturb_ratio_kpi = kpivalue.ratio
      end

      @disturb_ratio_kpi.each do |cell_name, kpivalue|
        @cell_kpivalue_map[cell_name] ||= CellKpiValue.new cell_name
        @cell_kpivalue_map[cell_name].disturb_ratio_kpi = kpivalue.ratio
        @cell_kpivalue_map[cell_name].disturb_strenth = kpivalue.sum_value
      end

      @disturb_ratio_kpi.each_detail do |ncell_name, scell_name, kpivalue|
        disturb_detail = DisturbDetail.new
        disturb_detail.ncell_name = ncell_name
        disturb_detail.scell_name = scell_name
        disturb_detail.distrub_ratio = kpivalue.ratio
        disturb_detail.distrub_count = kpivalue.valid_count
        disturb_detail.all_count = kpivalue.all_count
        disturb_detail.disturb_strenth = kpivalue.sum_value
        @disturb_details << disturb_detail
      end

      @disturb_ratio_kpi.each_overcover_kpi do |ncell_name, kpivalue|
        @cell_kpivalue_map[ncell_name] ||= CellKpiValue.new ncell_name
        @cell_kpivalue_map[ncell_name].overlap_count_kpi = kpivalue.valid_count
      end

      @high_disturb_ratio_kpi.each do |cell_name, kpivalue|
        @cell_kpivalue_map[cell_name] ||= CellKpiValue.new cell_name
        @cell_kpivalue_map[cell_name].high_disturb_ratio_kpi = kpivalue.ratio
      end
    end

    def worst_cell_name
      worst_cell_name = ""
      max_disturb = 0
      @disturb_ratio_kpi.each do |cell_name, kpivalue|
        if (cell_name != "" && kpivalue.sum_value > max_disturb)
          max_disturb = kpivalue.sum_value
          worst_cell_name = cell_name
        end
      end
      worst_cell_name
    end

    def to_file resultfile
      cal_kpi_value
      File.open(resultfile, "w") do |file|
        file.puts "等效SINR,#{@effectsinr_kpi.value}".encode('GBK')
        file.puts "过覆盖数,#{@overrange_kpi.value}".encode('GBK')
        file.puts "小区名,弱覆盖,重叠覆盖系数,邻区干扰,小区干扰,小区干扰强度,过覆盖数,高干扰".encode('GBK')
        cell_kpivalues_sort = @cell_kpivalue_map.values.sort_by do |cell_kpivalue|
          cell_kpivalue.disturb_strenth.to_f * -1
        end
        cell_kpivalues_sort.each do |cellkpivalue|
          dis_str = ""
          dis_str << "#{cellkpivalue.cell_name},#{cellkpivalue.weakcover_ratio_kpi},#{cellkpivalue.overlapcover_ratio_kpi},"
          dis_str << "#{cellkpivalue.ncell_disturb_ratio_kpi},#{cellkpivalue.disturb_ratio_kpi},#{cellkpivalue.disturb_strenth},#{cellkpivalue.overlap_count_kpi},#{cellkpivalue.high_disturb_ratio_kpi}"
          file.puts dis_str
        end
      end

      detail_resultfile = resultfile.sub '.csv', '_detal.csv'
      File.open("#{detail_resultfile}", "w") do |file|
        file.puts "邻小区,源小区,干扰,干扰数,干扰强度,总数".encode('GBK')
        disturb_details_sort = @disturb_details.sort_by do |disturb|
          disturb.disturb_strenth * -1
        end
        disturb_details_sort.each do |disturb_detail|
          dis_str = ""
          dis_str << "#{disturb_detail.ncell_name},#{disturb_detail.scell_name},#{disturb_detail.distrub_ratio},#{disturb_detail.distrub_count},#{disturb_detail.disturb_strenth},#{disturb_detail.all_count}"
          file.puts dis_str
        end
      end

    end

  end

  class DisturbDetail
    attr_accessor :ncell_name, :scell_name, :distrub_ratio, :distrub_count, :all_count, :disturb_strenth

  end

  class CellKpiValue
    attr_accessor :cell_name, :weakcover_ratio_kpi, :overlapcover_ratio_kpi, :disturb_strenth,
                  :ncell_disturb_ratio_kpi, :disturb_ratio_kpi, :overlap_count_kpi, :high_disturb_ratio_kpi

    def initialize cell_name
      @cell_name = cell_name
    end
  end

  class KpiValue

    attr_reader :valid_count, :all_count, :sum_value, :sum_count
    def initialize
      @valid_count = 0
      @all_count = 0
      @sum_value = 0.0
      @sum_count = 0
    end

    def add_valid
      @valid_count += 1
      @all_count += 1
    end

    def add_invalid
      @all_count += 1
    end

    def add_value value
      @sum_value += value.to_f
      @sum_count += 1
    end

    def ratio
      if (@all_count == 0)
        ratio = 0
      else
        ratio = 1.0 * @valid_count / @all_count
      end
      ratio
    end

    def avg
      @sum_value / @sum_count
    end

    def add_kpivalue kpivalue
      @valid_count += kpivalue.valid_count
      @all_count += kpivalue.all_count
      @sum_value += kpivalue.sum_value
      @sum_count += kpivalue.sum_count
    end
  end

  class BaseCellKpi

    include Enumerable

    attr :kpivalue_map

    # def initialize
    #   @kpivalue_map = {}
    # end

    def static pointdata
      unless pointdata.rsrp.to_s.empty?
        cell_name = pointdata.cell_name
        @kpivalue_map[cell_name] ||= KpiValue.new
        if valid? pointdata
          @kpivalue_map[cell_name].add_valid
        else
          @kpivalue_map[cell_name].add_invalid
        end
      end
    end

    def all_kpivalue
      kpivalue = KpiValue.new
      @kpivalue_map.values do |value|
        kpivalue.add_kpivalue value
      end
      kpivalue
    end

    def each
      @kpivalue_map.each do |cell_name, kpivalue|
        yield cell_name, kpivalue
      end
    end

  end



  # 小区弱覆盖系数：小区覆盖系数是对小区覆盖情况的判断，采用“小区弱覆盖采样点数÷总采样点数”。 
  # 小区弱覆盖采样点数为小区RSCP（或RSRP）测量值低于弱覆盖阈值的采样点数。
  class WeakCoverRatioKpi < BaseCellKpi

    def initialize weak_cover_threshold
      @kpivalue_map = {}
      @weak_cover_threshold = weak_cover_threshold
    end

    def valid? pointdata
      f_rsrp = pointdata.rsrp.to_f
      f_rsrp < @weak_cover_threshold
    end
  end


  # 小区重叠覆盖系数：小区重叠覆盖系数是同时满足重叠覆盖小区数和邻区干扰强度判断的采样点占比的统计，
  # 采用“重叠覆盖小区数>重叠覆盖小区数阈值且邻区干扰强度>邻区干扰强度阈值的采样点数÷总采样点数”(第一象限)。
  class OverLapCoverRatioKpi < BaseCellKpi

    def initialize disturb_strength_threshold, over_range_count_threshold
      @kpivalue_map = {}
      @disturb_strength_threshold = disturb_strength_threshold
      @over_range_count_threshold = over_range_count_threshold
    end

    def valid? pointdata
      pointdata.disturb > @disturb_strength_threshold && pointdata.over_range_count > @over_range_count_threshold
    end

  end

  # 小区邻区干扰强度系数：小区邻区干扰强度系数采用“重叠覆盖小区数<重叠覆盖小区数阈值且邻区干扰强度>邻区
  # 干扰强度阈值的采样点占比”（第四象限）。
  class NCellDisturbRatioKpi < BaseCellKpi

    def initialize disturb_strength_threshold, over_range_count_threshold
      @kpivalue_map = {}
      @disturb_strength_threshold = disturb_strength_threshold
      @over_range_count_threshold = over_range_count_threshold
    end

    def valid? pointdata
      pointdata.disturb > @disturb_strength_threshold && pointdata.over_range_count < @over_range_count_threshold
    end

  end

  # 小区干扰系数: 某小区作为邻区的采样点中，“作为邻区的该小区电平值与主服务小区电平值之差大于邻区干扰
  # 阈值的采样点数/作为邻区测到的总采样点数”为该小区的小区干扰系数。所有作为邻区的采样点必须满足“测得
  # 电平值>邻区有效性阈值”。
  class DisturbRatioKpi

    include Enumerable

    def initialize disturb_threshold, ncell_valid_threshold, over_cover_ratio_threshold
      @kpivalue_map = {}
      @kpivalue_detail_map = {}
      @over_cover_kpi_map = {}
      @disturb_threshold = disturb_threshold
      @ncell_valid_threshold = ncell_valid_threshold
      @over_cover_ratio_threshold = over_cover_ratio_threshold
    end

    def static pointdata
      nei_cells = pointdata.nei_cells
      nei_cells.each do |nei_cell|

        f_ncell_rsrp = nei_cell.rsrp.to_f
        f_scell_rsrp = pointdata.rsrp.to_f
        
        nei_cell_name = nei_cell.cell_name
        @kpivalue_detail_map[nei_cell_name] ||= {}
        @kpivalue_map[nei_cell_name] ||= KpiValue.new
        kpivalue = @kpivalue_map[nei_cell_name]
        scell_map = @kpivalue_detail_map[nei_cell_name]
        scell_name = pointdata.cell_name
        scell_map[scell_name] ||= KpiValue.new

        if ((f_ncell_rsrp - f_scell_rsrp) > @disturb_threshold && f_ncell_rsrp > @ncell_valid_threshold)
          scell_map[scell_name].add_valid
          kpivalue.add_valid
        else
          scell_map[scell_name].add_invalid
          if (f_ncell_rsrp > @ncell_valid_threshold)
            kpivalue.add_invalid
          end
        end
        disturb_strenth = 10**(f_ncell_rsrp/10 - f_scell_rsrp/10)
        scell_map[scell_name].add_value disturb_strenth
        kpivalue.add_value disturb_strenth
      end
    end

    def each
      @kpivalue_map.each do |ncell_name, kpivalue|
        yield ncell_name, kpivalue
      end
    end

    def each_detail
      @kpivalue_detail_map.each do |ncell_name, scell_map|
        scell_map.each do |scell_name, kpivalue|
          yield ncell_name, scell_name, kpivalue
        end
      end
    end

    def each_overcover_kpi
      cal_over_cover_kpi
      @over_cover_kpi_map.each do |ncell_name, kpivalue|
        yield ncell_name, kpivalue
      end
    end

    # 小区过覆盖系数：某小区作为邻区时，与主服务小区之间“小区干扰系数”大于过覆盖阈值的主服务小区个数。
    def cal_over_cover_kpi
      @over_cover_kpi_map = {}
      @kpivalue_detail_map.each do |ncell_name, value_map|
        value_map.each do |scell_name, kpivalue|
          @over_cover_kpi_map[ncell_name] ||= KpiValue.new
          if 1.0 * kpivalue.valid_count / kpivalue.all_count > @over_cover_ratio_threshold
            @over_cover_kpi_map[ncell_name].add_valid
          else
            @over_cover_kpi_map[ncell_name].add_invalid
          end
        end
      end
    end
  end

  # 小区高干扰率：某小区SINR、等效SINR或C/I<高干扰阈值的采样点数/总采样点数。
  class HighDisturbRatioKpi < BaseCellKpi

    def initialize high_disturb_threshold
      @kpivalue_map = {}
      @high_disturb_threshold = high_disturb_threshold
    end

    def valid? pointdata
      pointdata.effect_sinr.to_f < @high_disturb_threshold
    end
    
  end

  # 全网等效SINR的计算，求平均值
  class EffectSinrKpi

    def initialize
      @kpivalue = KpiValue.new  
    end

    def static pointdata
      unless pointdata.effect_sinr.to_s.empty?
        @kpivalue.add_value pointdata.effect_sinr
      end
    end

    def value
      @kpivalue.avg
    end
  end

  class OverRangeKpi < EffectSinrKpi
    
    def static pointdata
      unless pointdata.over_range_count.to_s.empty?
        @kpivalue.add_value pointdata.over_range_count
      end
    end
  end

end