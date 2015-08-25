require 'spec_helper'

RSpec.describe 'Dalliance' do
  subject { DallianceModel.create }

  before(:all) do
    I18n.backend.store_translations(:en, YAML.load_file(File.open('./config/locales/en.yml'))['en'])
  end

  context "self#dalliance_status_in_load_select_array" do
    it "should return [state, human_name]" do
      expect(DallianceModel.dalliance_status_in_load_select_array).to eq([
        ["Completed", "completed"],
        ["Pending", "pending"],
        ["Processing", "processing"],
        ["Processing Error", "processing_error"],
        ["Validation Error", "validation_error"]
      ])
    end
  end

  context "human_attribute_name" do
    it "should display the correct locale" do
      expect(DallianceModel.human_attribute_name(:dalliance_status)).to eq ('Status')
    end
  end
end
