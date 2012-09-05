require 'rubygems'
require 'bundler/setup'

#Automatically included in a rails app...
require 'active_support'
require 'state_machine'

#Required for testing...
require 'delayed_job'
require 'delayed_job_active_record'
require 'resque'

require 'dalliance'

RSpec.configure do |config|
  #http://blog.rubyhead.com/2010/04/27/database-during-tests/
  config.before do
    ActiveRecord::Base.connection.begin_db_transaction
    ActiveRecord::Base.connection.increment_open_transactions
  end

  config.after do
    if ActiveRecord::Base.connection.open_transactions != 0
      ActiveRecord::Base.connection.rollback_db_transaction
      ActiveRecord::Base.connection.decrement_open_transactions
    end
  end
end

#We don't need a full rails app to test...
require 'support/active_record'
