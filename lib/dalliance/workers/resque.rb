module Dalliance
  module Workers
    class Resque
      @queue = :dalliance

      def self.enqueue(instance)
        ::Resque.enqueue(self, instance.class.name, instance.id)
      end

      def self.perform(instance_klass, instance_id)
        instance_klass.constantize.find(instance_id).dalliance_process(true)
      end
    end
  end
end