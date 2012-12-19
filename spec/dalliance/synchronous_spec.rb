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
  end
end