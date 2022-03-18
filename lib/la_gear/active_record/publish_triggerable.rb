module LaGear
  module ActiveRecord
    module PublishTriggerable
      def publish_after_commit(routing_key, opts)
        publish_method = "publish_#{routing_key}"
        la_gear_opts = la_gear_options(opts)
        define_method publish_method do
          message = block_given? ? yield(self) : {}
          Bus.publish(routing_key.to_s, message, la_gear_opts)
        end
        after_commit publish_method.to_sym, after_commit_options(opts)
      end

      def send_after_commit(routing_key, opts)
        publish_method = "publish_#{routing_key}"
        la_gear_opts = la_gear_options(opts)
        define_method publish_method do
          message = block_given? ? yield(self) : {}
          Bus.publish_local(routing_key.to_s, message, la_gear_opts)
        end
        after_commit publish_method.to_sym, after_commit_options(opts)
      end

      def send_in_after_commit(routing_key, opts, interval)
        publish_method = "publish_#{routing_key}"
        la_gear_opts = la_gear_options(opts)
        define_method publish_method do
          message = block_given? ? yield(self) : {}
          Bus.publish_local_in(routing_key.to_s, message, la_gear_opts, interval)
        end
        after_commit publish_method.to_sym, after_commit_options(opts)
      end

      private

      def after_commit_options(opts = {})
        opts.reject { |k, _v| [:version, :suffix].include?(k) }
      end

      def la_gear_options(opts = {})
        opts.select { |k, _v| [:version, :suffix].include?(k) }
      end
    end
  end
end
