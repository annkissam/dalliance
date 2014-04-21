require 'dalliance'
require 'dalliance/schema'

module Dalliance
  class Engine < ::Rails::Engine
    initializer 'dalliance.active_record' do
      ActiveSupport.on_load :active_record do
        include Dalliance::Glue

        ActiveRecord::ConnectionAdapters::TableDefinition.send(:include, Dalliance::Schema)
      end
    end
  end
end
