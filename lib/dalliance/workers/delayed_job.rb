module Dalliance
  module Workers
    if defined?(Rails) && ((::Rails::VERSION::MAJOR == 4 && ::Rails::VERSION::MINOR >= 2) || ::Rails::VERSION::MAJOR >= 5)
      class DelayedJob < ::ActiveJob::Base
        queue_as :dalliance

        def self.enqueue(instance, queue = 'dalliance')
          Dalliance::Workers::DelayedJob.set(queue: queue).perform_later(instance.class.name, instance.id)
        end

        def perform(instance_klass, instance_id)
          instance_klass.constantize.find(instance_id).dalliance_process(true)
        end

        #Delayed job automatically retries, so rescue the error
        def self.rescue_error?
          true
        end
      end
    else
      class DelayedJob < Struct.new(:instance_klass, :instance_id)
        def self.enqueue(instance, queue = 'dalliance')
          ::Delayed::Job.enqueue(self.new(instance.class.name, instance.id), :queue => queue)
        end

        def perform
          instance_klass.constantize.find(instance_id).dalliance_process(true)
        end

        #Delayed job automatically retries, so rescue the error
        def self.rescue_error?
          true
        end
      end
    end
  end
end
