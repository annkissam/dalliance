module Dalliance
  module Workers
    class DelayedJob < Struct.new(:instance_klass, :instance_id)
      def self.enqueue(instance, queue = 'dalliance')
        ::Delayed::Job.enqueue(self.new(instance.class.name, instance.id), :queue => queue)
      end

      def perform
        instance_klass.constantize.find(instance_id).dalliance_process(true)
      end
    end
  end
end