class CreateDallianceProgressMeters < ActiveRecord::Migration
  def self.up
    create_table :dalliance_progress_meters do |t|
      t.belongs_to :dalliance_progress_model, :polymorphic => true

      t.integer :current_count
      t.integer :total_count
      t.integer :progress

      t.timestamps
    end

    add_index     :dalliance_progress_meters, [:dalliance_progress_model_id, :dalliance_progress_model_type], :name => 'by_dalliance_progress_model'
  end

  def self.down
    remove_index  :dalliance_progress_meters, :name => 'by_dalliance_progress_model'

    drop_table    :dalliance_progress_meters
  end
end