require "spec_helper"

module SpanReport::Process
  describe NodebReport do
    let(:report) { NodebReport.new }
    let(:logformat) { SpanReport::Model::Logformat.instance }

    before(:all) do
      logformat.load_xml("config/LogFormat_100.xml")
    end

    it "should be reg pci and freq" do
      report.add_nodeb_cell_info(Array.new)
      report.get_needed_ies(1188).size.should == 2
    end
  end
end