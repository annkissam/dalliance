require 'spec_helper'

describe DallianceModel do
  subject { DallianceModel.create }

  before(:all) do
    Dalliance.options[:background_processing] = true
  end

  context "no delay method" do
    before(:all) do
      DallianceModel.dalliance_options[:dalliance_method] = :dalliance_success_method
      DallianceModel.dalliance_options[:delay_method] = :not_delay
    end

    it "should raise an error" do
      expect { subject.dalliance_background_process }.to raise_error(NoMethodError)
    end
  end

  context "success" do
    before(:all) do
      DallianceModel.dalliance_options[:dalliance_method] = :dalliance_success_method
      DallianceModel.dalliance_options[:delay_method] = :delay
    end

    it "should not call the dalliance_method w/o a Delayed::Worker" do
      subject.dalliance_background_process
      subject.reload

      subject.should_not be_successful
      Delayed::Job.count.should == 1
    end

    it "should call the dalliance_method w/ a Delayed::Worker" do
      subject.dalliance_background_process
      Delayed::Worker.new.work_off
      subject.reload

      subject.should be_successful
      Delayed::Job.count.should == 0
    end

    it "should set the dalliance_status to completed" do
      subject.dalliance_background_process
      Delayed::Worker.new.work_off
      subject.reload

      subject.should be_completed
    end

    it "should set the dalliance_progress to 100" do
      subject.dalliance_background_process
      Delayed::Worker.new.work_off
      subject.reload

      subject.dalliance_progress.should == 100
    end
  end

  context "raise error" do
    before(:all) do
      DallianceModel.dalliance_options[:dalliance_method] = :dalliance_error_method
      DallianceModel.dalliance_options[:delay_method] = :delay
    end

    it "should NOT raise an error" do
      subject.dalliance_background_process

      Delayed::Worker.new.work_off

      Delayed::Job.count.should == 0
    end

    it "should store the error" do
      subject.dalliance_background_process
      Delayed::Worker.new.work_off
      subject.reload

      subject.dalliance_error_hash.should_not be_empty
      subject.dalliance_error_hash[:error].should == RuntimeError.name #We store the class name...
      subject.dalliance_error_hash[:message].should == 'RuntimeError'
      subject.dalliance_error_hash[:backtrace].should_not be_blank
    end

    it "should set the dalliance_status to processing_error" do
      subject.dalliance_background_process
      Delayed::Worker.new.work_off
      subject.reload

      subject.should be_processing_error
    end

    it "should set the dalliance_progress to 0" do
      subject.dalliance_background_process
      Delayed::Worker.new.work_off
      subject.reload

      subject.dalliance_progress.should == 0
    end
  end
end