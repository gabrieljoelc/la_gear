module LaGear
  module Bus
    Sidekiq::Extensions.enable_delay! if Sidekiq::Extensions.respond_to?(:enable_delay!)

    def init_pool(size = ::Sidekiq.options[:concurrency],
                       timeout = 3)
      $publisher = ConnectionPool.new(
        size: size,
        timeout: timeout
      ) { ::LaGear::Publisher.new }

      $publisher.with do |bus|
        fail 'Bus is lost!' unless bus.is_a?(LaGear::Publisher)
      end
    end
    module_function :init_pool

    def publish(routing_key, msg, la_gear_opts = {}, bunny_opts = {}, sidekiq_opts = {})
      routing_key = NamespaceUtility.adjust_routing_key(routing_key, la_gear_opts)
      DelayablePublisher.sidekiq_delay(sidekiq_opts).publish(routing_key, msg, bunny_opts)
    end
    module_function :publish

    def publish_in(interval, routing_key, msg, la_gear_opts = {}, bunny_opts = {}, sidekiq_opts = {})
      routing_key = NamespaceUtility.adjust_routing_key(routing_key, la_gear_opts)
      DelayablePublisher.sidekiq_delay_for(interval, sidekiq_opts).publish(routing_key, msg, bunny_opts)
    end
    module_function :publish_in

    def publish_at(timestamp, routing_key, msg, la_gear_opts = {}, bunny_opts = {}, sidekiq_opts = {})
      routing_key = NamespaceUtility.adjust_routing_key(routing_key, la_gear_opts)
      DelayablePublisher.sidekiq_delay_until(timestamp, sidekiq_opts).publish(routing_key, msg, bunny_opts)
    end
    module_function :publish_at

    def publish_local(routing_key, msg, la_gear_opts = {})
      routing_key = NamespaceUtility.adjust_routing_key(routing_key, la_gear_opts)
      NamespaceUtility.local_worker(routing_key).perform_async(*msg.values)
    end
    module_function :publish_local

    def publish_local_in(routing_key, msg, la_gear_opts = {}, interval)
      routing_key = NamespaceUtility.adjust_routing_key(routing_key, la_gear_opts)
      NamespaceUtility.local_worker(routing_key).perform_in(interval, *msg.values)
    end
    module_function :publish_local_in

    class NamespaceUtility
      class << self
        def local_worker(routing_key)
          routing_key.split('.').map(&:classify).join('::').constantize
        end

        def adjust_routing_key(routing_key, opts = {})
          if opts.key?(:version)
            routing_key = add_version(routing_key, opts[:version])
          elsif opts.key?(:suffix)
            routing_key = add_suffix(routing_key, opts[:suffix])
          end

          routing_key
        end

        def add_version(routing_key, version)
          return add_suffix(routing_key, "v#{version}") if version.present?
          routing_key
        end

        def add_suffix(routing_key, suffix)
          return "#{routing_key}.#{suffix}" if suffix.present?
          routing_key
        end
      end
    end

    class DelayablePublisher
      def self.publish(routing_key, msg, opts = {})
        opts = opts.merge(to_queue: routing_key)
        if $publisher
          $publisher.with do |publisher|
            publisher.publish(msg, opts)
          end
        else # this is what integration tests might use
          LaGear::Publisher.new.publish(msg, opts)
        end
      end
    end
  end
end
