# encoding: utf-8

module SpanReport::Simulate

  class PointKpiProcess

    def self.process_pointdata pointdata, config_map
      OverRangeCount.static pointdata, config_map
      NCellDisturbCount.static pointdata, config_map
      EffectSinrCount.static pointdata, config_map
    end
  end


  #########################################
  # 过覆盖数统计，统计每个采样点
  # 与主服务小区电平值相差小于邻区干扰阈值的小区个数；
  # 即，邻小区电平值与主服务小区电平值之差大于邻区干扰阈值，
  # 则认为邻小区对主服务小区会产生干扰
  # 计算同一时刻满足条件的小区个数（包含本小区）。
  #########################################
  class OverRangeCount

    def self.static pointdata, config_map
      over_range_count = 1
      return over_range_count if pointdata.rsrp.to_s.empty?
      f_rsrp = pointdata.rsrp.to_f
      ncells = pointdata.nei_cells
      ncells.each do |ncell|
        next if ncell.rsrp.to_s.empty?
        if ncell.rsrp.to_f - f_rsrp > config_map[DISTURB_THRESHOLD].to_f
          over_range_count += 1
        end
      end
      pointdata.over_range_count = over_range_count
    end
  end

  #########################################
  # 邻区干扰强度计算，统计每个采样点
  # 通过加权统计计算，获取与主服务小区同频的邻区，对主服务小区的干扰情况。
  # 在同频组网情况下，道路上弱于服务小区信号邻区干扰阈值范围内的邻区信号均会对主信号产生较强干扰
  # 且场强和最强信号差值越小其干扰强度越高
  # 通过对邻区信号进行加权统计可以精确反映邻区干扰强度。
  # 小区邻区干扰强度μ=∑μi =∑(10^(Ni/10)/10^(N1/10))
  # ➢ μi为干扰小区加权值； 
  # ➢ Ni为干扰小区信号强度和服务小区信号强度的差值；
  # ➢ N1为邻区干扰阈值.
  #########################################
  class NCellDisturbCount

    def self.static pointdata, config_map
      disturb = 0.0
      unless pointdata.rsrp.to_s.empty?
        f_rsrp = pointdata.rsrp.to_f
        ncells = pointdata.nei_cells
        ncells.each do |ncell|
          next if ncell.rsrp.to_s.empty?
          if ncell.rsrp.to_f - f_rsrp > config_map[DISTURB_THRESHOLD].to_f
            disturb += 10**(ncell.rsrp.to_f/10 - f_rsrp/10) / 10**(config_map[DISTURB_THRESHOLD].to_f/10)
          end
        end
      end
      pointdata.disturb = disturb
    end
  end

  ##############################################
  # 等效SINR计算
  # 等效SINR=S/(I+N), I来自各邻区的RSCP测量值， S指服务小区RSCP测量值；
  # S=10^(-67dbm/10)转换dbm为线性值；
  # I=10^(-62/10)+10^ (-70/10)+10^ (-74/10) +2*10^ (-86/10)+2*10^ (-87/10)+10^ (-90/10)；
  # N=10^ (-108/10)，N为网络底噪，通常可以忽略；
  # 等效SINR=-5.9db。
  ##############################################

  class EffectSinrCount
    def self.static pointdata, config_map
      effect_sinr = 0.0
      unless pointdata.rsrp.to_s.empty?
        f_s = 10**(pointdata.rsrp.to_f/10)
        f_i = 0.0
        f_rsrp = pointdata.rsrp.to_f
        ncells = pointdata.nei_cells
        ncells.each do |ncell|
          f_i += 10**(ncell.rsrp.to_f/10) unless ncell.rsrp.to_s.empty?
        end
        # f_n = 0
        f_n = 10**(-108.0/10)
        effect_sinr = f_s/(f_i + f_n)
      end
      pointdata.effect_sinr = 10 * Math.log10(effect_sinr)
    end
  end
end

