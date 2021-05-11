module Dalliance
  module Workers
    if defined?(Rails)
      class Resque < ::ActiveJob::Base
        queue_as :dalliance

        def self.enqueue(instance, queue = 'dalliance', perform_method)
          Dalliance::Workers::Resque
            .set(queue: queue)
            .perform_later(instance.class.name, instance.id, perform_method.to_s)
        end

        def self.dequeue(instance)
          redis = ::Resque.redis
          queue = instance.processing_queue

          redis.everything_in_queue(queue).each do |string|
            # Structure looks like, e.g.
            # { 'class' => 'ActiveJob::...', 'args' => [{ 'arguments' => ['SomeClass', 123, 'dalliance_process'] }] }
            data = ::Resque.decode(string)
            dalliance_args = data['args'][0]['arguments']

            if dalliance_args == [instance.class.name, instance.id, 'dalliance_process'] ||
               dalliance_args == [instance.class.name, instance.id, 'dalliance_reprocess']
              redis.remove_from_queue(queue, string)
            end
          end
        end

        def perform(instance_klass, instance_id, perform_method)
          instance_klass
            .constantize
            .find(instance_id)
            .send(perform_method, true)
        end

        #Resque fails, so don't rescue the error
        def self.rescue_error?
          false
        end
      end
    else
      class Resque
        def self.enqueue(instance, queue = 'dalliance', perform_method)
          ::Resque.enqueue_to(queue, self, instance.class.name, instance.id, perform_method.to_s)
        end

        def self.dequeue(instance)
          redis = ::Resque.redis
          queue = instance.processing_queue

          redis.everything_in_queue(queue).each do |string|
            # Structure looks like, e.g.
            # { 'class' => 'ActiveJob::...', 'args' => [{ 'arguments' => ['SomeClass', 123, 'dalliance_process'] }] }
            data = ::Resque.decode(string)
            dalliance_args = data['args'][0]['arguments']

            if dalliance_args == [instance.class.name, instance.id, 'dalliance_process'] ||
               dalliance_args == [instance.class.name, instance.id, 'dalliance_reprocess']
              redis.remove_from_queue(queue, string)
            end
          end
        end

        def self.perform(instance_klass, instance_id, perform_method)
          instance_klass
            .constantize
            .find(instance_id)
            .send(perform_method, true)
        end

        #Resque fails, so don't rescue the error
        def self.rescue_error?
          false
        end
      end
    end
  end
end
