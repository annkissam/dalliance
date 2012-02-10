require 'rails/generators/migration'
require 'rails/generators/active_record'

module Dalliance
  class ProgressMeterGenerator < Rails::Generators::Base
    include Rails::Generators::Migration

    desc "Create a migration to add dalliance_progress_meters"

    def self.source_root
      @source_root ||= File.expand_path('../templates', __FILE__)
    end

    def self.next_migration_number(path)
      ActiveRecord::Generators::Base.next_migration_number(path)
    end

    def generate_migration
      migration_template 'migration.rb', 'db/migrate/create_dalliance_progress_meters'
    end
  end
end