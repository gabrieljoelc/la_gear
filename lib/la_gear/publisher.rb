module LaGear
  class Publisher < ::Sneakers::Publisher
    attr_accessor :exchange

    def publish(msg, opts = {})
      super(self.class.serialize(msg), opts)
    end

    def self.serialize(msg)
      msg.to_json
    end

    private

    def ensure_connection!
      opts = { heartbeat: @opts[:heartbeat] }
      opts.merge!(vhost: @opts[:vhost]) if @opts[:vhost]
      @bunny = Bunny.new(@opts[:amqp_publish] || @opts[:amqp], opts)
      @bunny.start
      @channel = @bunny.create_channel
      @exchange = @channel.exchange(@opts[:exchange], @opts[:exchange_options])
    end

    def connected?
      @bunny && @bunny.connected?
    end
  end
end
