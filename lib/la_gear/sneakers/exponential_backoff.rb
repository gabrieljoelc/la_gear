module LaGear
  module Sneakers
    module Handlers
      class ExponentialBackoff
        def initialize(channel, _queue, opts)
          @channel = channel
          @opts = opts

          exchange = @opts.fetch(:exchange)
          @handler_opts = @opts.fetch(:handler_opts, {})

          retry_name = @handler_opts.fetch(:retryexchange, "#{exchange}.retry")
          error_name = @handler_opts.fetch(:errorexchange, "#{exchange}.error")

          @publish_channel = setup_publish_channel
          @retry_exchange = setup_retry(@publish_channel, retry_name, exchange)
          @error_exchange = setup_error(@publish_channel, error_name)

          @max_retries = @handler_opts.fetch(:max_retries, 5)
          @expiration = @handler_opts.fetch(:expiration, 1000)
        end

        def acknowledge(delivery_info, _metadata, _msg)
          @channel.acknowledge(delivery_info.delivery_tag, false)
        end

        def reject(hdr, props, msg, _requeue = false)
          retry_or_error(hdr, props, msg, 'rejected')
        end

        def error(hdr, props, msg, err)
          retry_or_error(hdr, props, msg, err.to_s)
        end

        def timeout(hdr, props, msg)
          error(hdr, props, msg, 'Timeout: Sneakers worker timedout.')
        end

        def noop(_delivery_info, _metadata, _msg); end

        private

        def retry_or_error(hdr, props, msg, reason, _requeue=false)
          retries = get_retries(props[:headers])
          if retries >= @max_retries
            @error_exchange.publish(
              msg,
              routing_key: @handler_opts.fetch(:routing_key, hdr.routing_key),
              headers: { 'sneakers-error-reason' => reason || 'Doh! No reason given. :(' }
            )
          else
            expire_delay = get_expire_delay(retries)

            @retry_exchange.publish(msg,
                                    routing_key: @handler_opts.fetch(:routing_key, hdr.routing_key),
                                    expiration: expire_delay,
                                    headers: {
                                      'sneakers-retries' => retries + 1,
                                      'sneakers-retry-reason' => reason || 'Doh! No reason given. :('
                                    })
          end
          @channel.acknowledge(hdr.delivery_tag, false)
        rescue => e
          logger.fatal "#{self} #{e}, hdr.routing_key #{hdr.routing_key}, props #{props}, msg #{msg}, reason #{reason}, handler_opts #{@handler_opts}, retries #{retries}"
        end

        def setup_retry(publish_channel, retry_name, exchange)
          retry_exchange = publish_channel.exchange(retry_name,
                                                    type: 'topic',
                                                    durable: 'true')
          retry_queue = publish_channel.queue(retry_name,
                                              durable: 'true',
                                              arguments: {
                                                :'x-dead-letter-exchange' => exchange,
                                              })
          retry_queue.bind(retry_exchange, routing_key: '#')
          trace(retry_queue, "#{self} retry queue created.")
          retry_exchange
        end

        def setup_error(publish_channel, error_name)
          error_exchange = publish_channel.exchange(error_name,
                                                    type: 'topic',
                                                    durable: 'true')
          error_queue = publish_channel.queue(error_name, durable: 'true')
          error_queue.bind(error_exchange, routing_key: '#')
          trace(error_queue, "#{self} error queue created.")
          error_exchange
        end

        def setup_publish_channel
          return @channel unless @opts.to_hash.include?(:amqp_publish)
          publish_bunny = Bunny.new(@opts[:amqp_publish], vhost: @opts[:vhost], heartbeat: @opts[:heartbeat])
          publish_bunny.start
          publish_channel = publish_bunny.create_channel
          publish_channel.prefetch(@opts[:prefetch])
          logger.warn "#{self} publish endpoint used: #{@opts[:amqp_publish]}, vhost #{@opts[:vhost]}"
          publish_channel
        end

        def trace(queue, msg)
          logger.debug "[#{Thread.current}][#{queue.name}][#{queue.options}] #{msg}"
        end

        def logger
          ::Sneakers.logger
        end

        def get_expire_delay(failures = 0)
          failures = failures.to_i + 1
          @expiration * (2**failures)
        end

        def get_retries(headers)
          headers ||= {}
          headers.fetch('sneakers-retries', 0).to_i
        end
      end
    end
  end
end
