# encoding: utf-8


module SpanReport::Simulate
  class CellKpiProcess

    attr_reader :cell_kpivalue_map

    def initialize config_map
      weak_cover_threshold = config_map[TDL_WEAK_COVER_THRESHOLD]
      disturb_threshold = config_map[DISTURB_THRESHOLD]
      disturb_strength_threshold = config_map[DISTURB_STRENGTH_THRESHOLD]
      over_range_count_threshold = config_map[OVERLAP_COVER_THRESHOLD]
      ncell_valid_threshold = config_map[NCELL_VALID_THRESHOLD]
      over_cover_ratio_threshold = config_map[OVER_COVER_RATIO_THRESHOLD]
      high_disturb_threshold = config_map[HIGH_DISTURB_THRESHOLD]

      @weakcover_ratio_kpi = WeakCoverRatioKpi.new weak_cover_threshold
      @overlapcover_ratio_kpi = OverLapCoverRatioKpi.new disturb_strength_threshold, over_range_count_threshold
      @ncell_disturb_ratio_kpi = NCellDisturbRatioKpi.new disturb_strength_threshold, over_range_count_threshold
      @disturb_ratio_kpi = DisturbRatioKpi.new disturb_threshold, ncell_valid_threshold, over_cover_ratio_threshold
      @high_disturb_ratio_kpi = HighDisturbRatioKpi.new high_disturb_threshold
      @effectsinr_kpi = EffectSinrKpi.new

      @cell_kpivalue_map = {}
    end

    def process_pointdata pointdata
      @weakcover_ratio_kpi.static pointdata
      @overlapcover_ratio_kpi.static pointdata
      @ncell_disturb_ratio_kpi.static pointdata
      @disturb_ratio_kpi.static pointdata
      @high_disturb_ratio_kpi.static pointdata
      @effectsinr_kpi.static pointdata
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
      end

      @high_disturb_ratio_kpi.each do |cell_name, kpivalue|
        @cell_kpivalue_map[cell_name] ||= CellKpiValue.new cell_name
        @cell_kpivalue_map[cell_name].high_disturb_ratio_kpi = kpivalue.ratio
      end
    end

  end

  class CellKpiValue
    attr_accessor :cell_name, :weakcover_ratio_kpi, :overlapcover_ratio_kpi, 
                  :ncell_disturb_ratio_kpi, :disturb_ratio_kpi, :high_disturb_ratio_kpi

    def initialize cell_name
      @cell_name = cell_name
    end
  end

  class KpiValue

    attr_reader :valid_count, :all_count, :sum_value
    def initialize
      @valid_count = 0
      @all_count = 0
      @sum_value = 0.0
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
      @all_count += 1
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
      @sum_value / @all_count
    end

    def add_kpivalue kpivalue
      @valid_count += kpivalue.valid_count
      @all_count += kpivalue.all_count
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
      end

      def each
        @kpivalue_map.each do |ncell_name, kpivalue|
          yield ncell_name, kpivalue
        end
      end

    end

    # 小区过覆盖系数：某小区作为邻区时，与主服务小区之间“小区干扰系数”大于过覆盖阈值的主服务小区个数。
    def cal_over_cover_kpi
      @over_cover_kpi_map = {}
      @kpivalue_map.each do |ncell_name, value_map|
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
  end

end