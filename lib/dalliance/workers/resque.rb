module Dalliance
  module Workers
    class Resque
      def self.enqueue(instance, queue = 'dalliance')
        ::Resque.enqueue_to(queue, self, instance.class.name, instance.id)
      end

      def self.perform(instance_klass, instance_id)
        instance_klass.constantize.find(instance_id).dalliance_process(true)
      end
    end
  end
end