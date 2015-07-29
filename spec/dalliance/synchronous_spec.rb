require 'spec_helper'

RSpec.describe DallianceModel do
  subject { DallianceModel.create }

  before(:all) do
    DallianceModel.dalliance_options[:background_processing] = false
    DallianceModel.dalliance_options[:duration_column] = 'dalliance_duration'
  end

  context "success" do
    before(:all) do
      DallianceModel.dalliance_options[:dalliance_method] = :dalliance_success_method
    end

    it "should call the dalliance_method" do
      expect { subject.dalliance_background_process }.to change(subject, :successful).from(false).to(true)
    end

    it "should set the dalliance_status to completed" do
      expect { subject.dalliance_background_process }.to change(subject, :dalliance_status).from('pending').to('completed')
    end

    it "should set the dalliance_progress to 100" do
      expect { subject.dalliance_background_process }.to change(subject, :dalliance_progress).from(0).to(100)
    end

    it "should set the dalliance_duration" do
      expect(subject.dalliance_duration).to eq(nil)

      subject.dalliance_background_process
      subject.reload

      expect(subject.dalliance_duration).not_to eq(nil)
    end
  end

  context "raise error" do
    before(:all) do
      DallianceModel.dalliance_options[:dalliance_method] = :dalliance_error_method
    end

    it "should raise an error" do
      expect { subject.dalliance_background_process }.to raise_error(RuntimeError)
    end

    it "should store the error" do
      expect { subject.dalliance_background_process }.to raise_error(RuntimeError)

      expect(subject.dalliance_error_hash).not_to be_empty
      expect(subject.dalliance_error_hash[:error]).to eq(RuntimeError.name) #We store the class name...
      expect(subject.dalliance_error_hash[:message]).to eq('RuntimeError')
      expect(subject.dalliance_error_hash[:backtrace]).not_to be_blank
    end

    it "should set the dalliance_status to processing_error" do
      expect { subject.dalliance_background_process }.to raise_error(RuntimeError)

      expect(subject).to be_processing_error
    end

    it "should set the dalliance_progress to 0" do
      expect { subject.dalliance_background_process }.to raise_error(RuntimeError)

      expect(subject.dalliance_progress).to eq(0)
    end

    it "should handle persistance errors" do
      DallianceModel.dalliance_options[:dalliance_method] = :dalliance_error_method
      allow_any_instance_of(DallianceModel).to receive(:error_dalliance!).and_raise(RuntimeError.new)

      expect { subject.dalliance_background_process }.to raise_error(RuntimeError)

      expect(subject).to be_processing_error
      expect(subject.dalliance_error_hash).not_to be_empty
      expect(subject.dalliance_error_hash[:error]).to eq('Persistance Failure: See Logs')
    end

    context "error_notifier" do
      it "should pass the errors" do
        DallianceModel.dalliance_options[:error_notifier] = ->(error){ @error_report = "#{error}" }
        allow_any_instance_of(DallianceModel).to receive(:error_dalliance!).and_raise(RuntimeError.new)

        expect { subject.dalliance_background_process }.to raise_error(RuntimeError)

        expect(@error_report).to eq('RuntimeError')
      end
    end
  end

  context "validation error" do
    before(:all) do
      DallianceModel.dalliance_options[:dalliance_method] = :dalliance_validation_error_method
    end

    it "should store the error" do
      subject.dalliance_background_process

      expect(subject.dalliance_error_hash).not_to be_empty
      expect(subject.dalliance_error_hash[:successful]).to eq(['is invalid'])
    end

    it "should set the dalliance_status to validation_error" do
      expect { subject.dalliance_background_process }.to change(subject, :dalliance_status).from('pending').to('validation_error')
    end

    it "should set the dalliance_progress to 0" do
      subject.dalliance_background_process

      expect(subject.dalliance_progress).to eq(0)
    end

    it "should handle persistance errors" do
      DallianceModel.dalliance_options[:dalliance_method] = :dalliance_validation_error_method
      allow_any_instance_of(DallianceModel).to receive(:validation_error_dalliance!).and_raise(RuntimeError.new)

      subject.dalliance_background_process

      expect(subject).to be_validation_error
      expect(subject.dalliance_error_hash).not_to be_empty
      expect(subject.dalliance_error_hash[:error]).to eq('Persistance Failure: See Logs')
    end
  end

   context "destroy" do
    it "should return false when pending?" do
      subject.update_column(:dalliance_status, 'pending')
      expect(subject.destroy).to be_falsey
      expect(subject.errors[:dalliance_status]).to eq(['is invalid'])
    end

    it "should return false when processing?" do
      subject.update_column(:dalliance_status, 'processing')
      expect(subject.destroy).to be_falsey
      expect(subject.errors[:dalliance_status]).to eq(['is invalid'])
    end

    it "should return true when validation_error?" do
      subject.update_column(:dalliance_status, 'validation_error')
      expect(subject.destroy).to be_truthy
    end

    it "should return true when processing_error?" do
      subject.update_column(:dalliance_status, 'processing_error')
      expect(subject.destroy).to be_truthy
    end

    it "should return true when completed?" do
      subject.update_column(:dalliance_status, 'completed')
      expect(subject.destroy).to be_truthy
    end
  end
end
