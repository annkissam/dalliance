module Dalliance
  module Workers
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