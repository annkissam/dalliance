require 'dalliance'

module Dalliance
  if defined? Rails::Railtie
    class Railtie < Rails::Railtie
      initializer 'dalliance.active_record' do
        ActiveSupport.on_load :active_record do
          include Dalliance::Glue
        end
      end
    end
  end
end