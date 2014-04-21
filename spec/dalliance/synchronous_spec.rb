require 'spec_helper'

describe DallianceModel do
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
      lambda { subject.dalliance_background_process }.should change(subject, :successful).from(false).to(true)
    end

    it "should set the dalliance_status to completed" do
      lambda { subject.dalliance_background_process }.should change(subject, :dalliance_status).from('pending').to('completed')
    end

    it "should set the dalliance_progress to 100" do
      lambda { subject.dalliance_background_process }.should change(subject, :dalliance_progress).from(0).to(100)
    end

    it "should set the dalliance_duration" do
      subject.dalliance_duration.should == nil

      subject.dalliance_background_process
      subject.reload

      subject.dalliance_duration.should_not == nil
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

      subject.dalliance_error_hash.should_not be_empty
      subject.dalliance_error_hash[:error].should == RuntimeError.name #We store the class name...
      subject.dalliance_error_hash[:message].should == 'RuntimeError'
      subject.dalliance_error_hash[:backtrace].should_not be_blank
    end

    it "should set the dalliance_status to processing_error" do
      expect { subject.dalliance_background_process }.to raise_error(RuntimeError)

      subject.should be_processing_error
    end

    it "should set the dalliance_progress to 0" do
      expect { subject.dalliance_background_process }.to raise_error(RuntimeError)

      subject.dalliance_progress.should == 0
    end

    it "should handle persistance errors" do
      DallianceModel.dalliance_options[:dalliance_method] = :dalliance_error_method_with_state_machine_exception

      expect { subject.dalliance_background_process }.to raise_error(RuntimeError)

      subject.should be_processing_error
      subject.dalliance_error_hash.should_not be_empty
      subject.dalliance_error_hash[:error].should == 'Persistance Failure: See Logs'
    end
  end

  context "validation error" do
    before(:all) do
      DallianceModel.dalliance_options[:dalliance_method] = :dalliance_validation_error_method
    end

    it "should store the error" do
      subject.dalliance_background_process

      subject.dalliance_error_hash.should_not be_empty
      subject.dalliance_error_hash[:successful].should == ['is invalid']
    end

    it "should set the dalliance_status to validation_error" do
      lambda { subject.dalliance_background_process }.should change(subject, :dalliance_status).from('pending').to('validation_error')
    end

    it "should set the dalliance_progress to 0" do
      subject.dalliance_background_process

      subject.dalliance_progress.should == 0
    end

    it "should handle persistance errors" do
      DallianceModel.dalliance_options[:dalliance_method] = :dalliance_validation_error_method_with_state_machine_exception

      subject.dalliance_background_process

      subject.should be_validation_error
      subject.dalliance_error_hash.should_not be_empty
      subject.dalliance_error_hash[:error].should == 'Persistance Failure: See Logs'
    end
  end

   context "destroy" do
    it "should return false when pending?" do
      subject.update_column(:dalliance_status, 'pending')
      subject.destroy.should be_false
      subject.errors[:dalliance_status].should == ['is invalid']
    end

    it "should return false when processing?" do
      subject.update_column(:dalliance_status, 'processing')
      subject.destroy.should be_false
      subject.errors[:dalliance_status].should == ['is invalid']
    end

    it "should return true when validation_error?" do
      subject.update_column(:dalliance_status, 'validation_error')
      subject.destroy.should be_true
    end

    it "should return true when processing_error?" do
      subject.update_column(:dalliance_status, 'processing_error')
      subject.destroy.should be_true
    end

    it "should return true when completed?" do
      subject.update_column(:dalliance_status, 'completed')
      subject.destroy.should be_true
    end
  end
end
