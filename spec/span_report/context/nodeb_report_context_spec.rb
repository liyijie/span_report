require "spec_helper"

module SpanReport::Context
  describe NodebReportContext do
    let(:context) { NodebReportContext.new "/ruby/context" }

    it "should load relate" do
      context.load_config
      context.cell_info

    end
  end
end