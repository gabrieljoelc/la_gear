module LaGear
  class SneakersConfigurer
    class << self
      def configure_bi_amqp_endpoints(rx_uri_str, tx_uri_str)
        parser = UriParser.new(rx_uri_str)
        ::Sneakers.configure(
          amqp: parser.amqp,
          vhost: parser.vhost
        )
        parser = UriParser.new(tx_uri_str)
        ::Sneakers.configure(
          amqp_publish: parser.amqp,
          vhost_publish: parser.vhost
        )
      end
    end
  end
end
