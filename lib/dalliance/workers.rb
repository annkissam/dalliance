module Dalliance
	module Workers
    autoload :DelayedJob, 'dalliance/workers/delayed_job'
    autoload :Resque, 'dalliance/workers/resque'
  end
end