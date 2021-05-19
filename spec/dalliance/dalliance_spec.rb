require 'spec_helper'

RSpec.describe 'Dalliance' do
  subject { DallianceModel.create }

  before(:all) do
    I18n.backend.store_translations(:en, YAML.load_file(File.open('./config/locales/en.yml'))['en'])
  end

  context "self#dalliance_status_in_load_select_array" do
    it "should return [state, human_name]" do
      expect(DallianceModel.dalliance_status_in_load_select_array).to contain_exactly(
        ["Completed", "completed"],
        ["Pending", "pending"],
        ["Processing", "processing"],
        ["Processing Error", "processing_error"],
        ["Validation Error", "validation_error"],
        ["Cancellation Requested", "cancel_requested"],
        ['Cancelled', 'cancelled']
      )
    end
  end

  context "human_attribute_name" do
    it "should display the correct locale" do
      expect(DallianceModel.human_attribute_name(:dalliance_status)).to eq('Status')
    end
  end

  context "processing_queue" do
    before do
      DallianceModel.dalliance_options[:queue] = queue
    end

    context "string" do
      let(:queue) { 'dalliance_2'}

      specify{ expect(subject.processing_queue).to eq(queue) }
    end

    context "proc" do
      context "w/o args" do
        let(:queue) { Proc.new{ 'dalliance_2' } }

        specify{ expect(subject.processing_queue).to eq(queue.call) }
      end

      context "w/ args" do
        let(:queue) { Proc.new{ |_a,_b,_c| 'dalliance_2' } }

        specify{ expect(subject.processing_queue).to eq(queue.call) }
      end
    end
  end
end
