require 'active_record'

module Dalliance
  class ProgressMeter < ::ActiveRecord::Base
    self.table_name = 'dalliance_progress_meters'
    
    belongs_to :dalliance_progress_model, :polymorphic => true

    validates_presence_of :dalliance_progress_model

    #current_count should max out at total_count, but we'll allow you to miscount...
    validates_numericality_of :current_count, :only_integer => true, :greater_than_or_equal_to => 0#, :less_than_or_equal_to => Proc.new(&:total_count)
    validates_numericality_of :total_count,   :only_integer => true, :greater_than => 0
    validates_numericality_of :progress,      :only_integer => true, :greater_than_or_equal_to => 0, :less_than_or_equal_to => 100

    def current_count
      self[:current_count] ||= 0
    end
    
    def total_count
      self[:total_count] ||= 1
    end
    
    before_validation :calculate_progress

    def calculate_progress
      begin
        self.progress = (current_count.to_f / total_count.to_f * 100).to_i
        
        #Handle an incorrect total_count...
        self.progress = 100 if progress > 100
      rescue
        #what, are you diving by zero?
        self.progress = 0
      end
    end

    def increment!
      self.current_count += 1
      self.save!
    end
  end
end