module Dalliance
  module Workers
    if defined?(Rails)
      class DelayedJob < ::ActiveJob::Base
        queue_as :dalliance

        def self.enqueue(instance, queue = 'dalliance', perform_method)
          Dalliance::Workers::DelayedJob
            .set(queue: queue)
            .perform_later(instance.class.name, instance.id, perform_method.to_s)
        end

        def self.dequeue(_instance)
          # NOP
        end

        def perform(instance_klass, instance_id, perform_method)
          instance_klass
            .constantize
            .find(instance_id)
            .send(perform_method, true)
        end

        #Delayed job automatically retries, so rescue the error
        def self.rescue_error?
          true
        end
      end
    else
      class DelayedJob < Struct.new(:instance_klass, :instance_id, :perform_method)
        def self.enqueue(instance, queue = 'dalliance', perform_method)
          ::Delayed::Job.enqueue(
            self.new(instance.class.name, instance.id, perform_method),
            :queue => queue
          )
        end

        def self.dequeue(_instance)
          # NOP
        end

        def perform
          instance_klass
            .constantize
            .find(instance_id)
            .send(perform_method, true)
        end

        #Delayed job automatically retries, so rescue the error
        def self.rescue_error?
          true
        end
      end
    end
  end
end
