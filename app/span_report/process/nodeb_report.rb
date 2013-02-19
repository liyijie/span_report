# encoding: utf-8

module SpanReport::Process
  
  class NodebReport < Report

    PCI_IENAME = "TDDLTE_Scell_Radio_Parameters_Scell_PCI"
    FREQ_IENAME = "TDDLTE_Scell_Radio_Parameters_Frequency_DL"
    ########################################
    #处理日志中的一条数据
    #这里已经通过校验，已经是包含需要处理的数据
    #1. 把日志数据中相关的IE都能加入到IE缓存中
    #2. 如果是counter相关的数据，则计算相关的counter值
    #
    #########################################
    def initialize
      super
      @pci_freq_map = {}
    end

    def add_counter_cache counter_name, counter_ievalue, count_mode
      super counter_name, counter_ievalue, count_mode
      #对符合用户给定基站小区信息的，需要进行统计
      cell_pci = @ie_caches[PCI_IENAME]
      cell_freq = @ie_caches[FREQ_IENAME]
      cell_pci ||= ""
      cell_freq ||= ""
      pci_freq_key = "#{cell_pci}_#{cell_freq}"

      if @pci_freq_map.has_key? pci_freq_key
        cell_info = @pci_freq_map[pci_freq_key]
        nodeb_name = cell_info.nodeb_name
        cell_name = cell_info.cell_name
        nodeb_counter_name = "#{nodeb_name}$#{counter_name}"
        cell_counter_name = "#{cell_name}$#{counter_name}"
        super nodeb_counter_name, counter_ievalue, count_mode
        super cell_counter_name, counter_ievalue, count_mode
        SpanReport.logger.debug "nodeb_counter_name is:#{nodeb_counter_name}"
        SpanReport.logger.debug "cell_counter_name is:#{cell_counter_name}"
      end
    end

    def add_nodeb_cell_info cell_infos
      reg_cell_pci_freq_iename
      cell_infos.each do |cell_info|
        nodeb_name = cell_info.nodeb_name
        cell_name = cell_info.cell_name
        pci = cell_info.pci.to_i
        freq = cell_info.freq.to_i
        @pci_freq_map["#{pci}_#{freq}"] = cell_info
      end
      SpanReport.logger.debug "@pci_freq_map is:#{@pci_freq_map.inspect}"
    end

    def reg_cell_pci_freq_iename
      reg_iename PCI_IENAME, PCI_IENAME
      reg_iename FREQ_IENAME, FREQ_IENAME
    end

  end
end