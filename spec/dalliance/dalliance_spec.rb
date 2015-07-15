require 'spec_helper'

RSpec.describe 'Dalliance' do
  subject { DallianceModel.create }

  context "self#dalliance_status_in_load_select_array" do
    it "should return [state, human_name]" do
      expect(DallianceModel.dalliance_status_in_load_select_array).to eq([
        ["completed", "completed"],
        ["pending", "pending"],
        ["processing", "processing"],
        ["processing error", "processing_error"],
        ["validation error", "validation_error"]
      ])
    end
  end
end
