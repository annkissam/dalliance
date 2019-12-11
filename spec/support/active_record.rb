#Adapted from delayed_job_active_record
#https://github.com/collectiveidea/delayed_job_active_record

ActiveRecord::Base.establish_connection(:adapter => "sqlite3", :database => ":memory:")
ActiveRecord::Migration.verbose = false

ActiveRecord::Schema.define do
  create_table :dalliance_progress_meters, :force => true do |t|
    t.belongs_to :dalliance_progress_model, :polymorphic => true, index: { name: "by_dalliance_progress_model" }

    t.integer :current_count
    t.integer :total_count
    t.integer :progress

    t.timestamps null: false
  end

  # add_index     :dalliance_progress_meters, [:dalliance_progress_model_id, :dalliance_progress_model_type], :name => 'by_dalliance_progress_model'

  create_table :delayed_jobs, :force => true do |table|
    table.integer  :priority, :default => 0
    table.integer  :attempts, :default => 0
    table.text     :handler
    table.text     :last_error
    table.datetime :run_at
    table.datetime :locked_at
    table.datetime :failed_at
    table.string   :locked_by
    table.string   :queue
    table.timestamps  null: false
  end

  add_index :delayed_jobs, [:priority, :run_at], :name => 'delayed_jobs_priority'

  create_table :dalliance_models, :force => true do |t|
    t.text    :dalliance_error_hash
    t.string  :dalliance_status, :string, :null => false, :default => 'pending'
    t.integer :dalliance_duration

    t.boolean :successful, :default => false
    t.integer :reprocessed_count, default: 0
  end
end

# Purely useful for test cases...
class DallianceModel < ActiveRecord::Base
  #We're not using the railtie in tests...
  include Dalliance::Glue

  dalliance :dalliance_success_method,
            dalliance_reprocess_method: :dalliance_reprocess_method,
            :logger => nil

  def dalliance_success_method
    update_attribute(:successful, true)
  end

  def dalliance_reprocess_method
    update_attribute(:reprocessed_count, self.reprocessed_count + 1)
  end

  def dalliance_error_method
    raise RuntimeError
  end

  def dalliance_validation_error_method
    errors.add(:successful, :invalid)

    store_dalliance_validation_error!
  end
end
