module LaGear
  module Worker
    def self.included(base)
      if sidekiq_proc?
        base.extend(NoOpSneakersClassMethods)
      else
        base.send(:include, ::Sneakers::Worker)
        base.extend(SneakersClassMethods)

        base.from_queue base.default_queue_name, base.default_queue_opts
      end
      base.send(:include, ::Sidekiq::Worker)
      base.extend(DefaultClassMethods)
    end

    class << self
      def sidekiq_proc?
        $0.end_with?('sidekiq')
      end
    end

    module DefaultClassMethods
      def deserialize(msg)
        JSON.parse(msg)
      end
    end

    module SneakersClassMethods
      def app_name
        ::Sneakers::CONFIG.fetch(:app_name, 'sneakers').underscore
      end

      def default_queue_name
        @default_queue_name ||= "#{app_name}.#{routing_key}"
      end

      def default_queue_opts
        {
          routing_key: [*routing_key, retry_routing_key],
          queue_options: {
            arguments: default_queue_args
          }.merge(::Sneakers::CONFIG.fetch(:global_queue_options, {})),
          handler_opts: {
            routing_key: retry_routing_key
          }
        }
      end

      def routing_key
        @routing_key ||= name.underscore.tr('/', '.')
      end

      def retry_routing_key
        "#{default_queue_name}.retry"
      end

      def default_queue_args
        { 'x-dead-letter-exchange' => "#{::Sneakers::CONFIG.fetch(:exchange, 'sneakers').underscore}.retry" }
      end

      def subscribes_to(routing_key)
        @routing_key = routing_key
        @default_queue_name = "#{app_name}.#{name.underscore.tr('/', '.')}"
        from_queue(default_queue_name, default_queue_opts) unless Worker.sidekiq_proc?
      end
    end

    module NoOpSneakersClassMethods
      def from_queue(_dummy_name, _dummy_opts); end

      # we can save memory in the sidekiq process by no-oping sneakers methods
      # so it doesn't new up a bunny connection
      SneakersClassMethods.instance_methods(false).each { |m| define_method(m) { |*args| {} } }
    end

    def work(msg)
      msg = self.class.deserialize(msg)
      self.class.perform_async(*msg.values)
      ack!
    end
  end
end
