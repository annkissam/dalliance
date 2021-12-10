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

        def self.queued?(instance, queue_name)
          # All current jobs in the queue
          queued_jobs =
            ::Resque.redis.everything_in_queue(queue_name)
              .map(&::Resque.method(:decode))

          queued_jobs.any? do |job_info_hash|
            args = job_info_hash['args']
            next unless args.is_a?(Array)

            arg = args[0]
            next unless arg.is_a?(Hash)

            arg.fetch('arguments', []).first(2) ==
              [instance.class.name, instance.id]
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

        def self.queued?(instance, queue_name)
          # All current jobs in the queue
          queued_jobs =
            ::Resque.redis.everything_in_queue(queue_name)
              .map(&::Resque.method(:decode))

          queued_jobs.any? do |job_info_hash|
            args = job_info_hash['args']
            next unless args.is_a?(Array)

            arg = args[0]
            next unless arg.is_a?(Hash)

            arg.fetch('arguments', []).first(2) ==
              [instance.class.name, instance.id]
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
