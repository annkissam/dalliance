module Dalliance
  module Workers
    if defined?(Rails) && ((::Rails::VERSION::MAJOR == 4 && ::Rails::VERSION::MINOR >= 2) || ::Rails::VERSION::MAJOR >= 5)
      class Resque < ::ActiveJob::Base
        queue_as :dalliance

        def self.enqueue(instance, queue = 'dalliance', perform_method)
          Dalliance::Workers::Resque
            .set(queue: queue)
            .perform_later(instance.class.name, instance.id, perform_method.to_s)
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
