require 'spec_helper'

RSpec.describe 'Dalliance' do
  subject { DallianceModel.create }

  context "self#dalliance_status_in_load_select_array" do
    it "should return [state, human_name]" do
      expect(DallianceModel.dalliance_status_in_load_select_array).to eq([
        ["pending", :pending],
        ["processing", :processing],
        ["validation error", :validation_error],
        ["processing error", :processing_error],
        ["completed", :completed]
      ])
    end
  end
end
