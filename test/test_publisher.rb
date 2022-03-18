require_relative 'helper'

class TestPublisher < LaGear::Test
  describe LaGear::Publisher do
    attr_reader :mock_bunny

    before do
      Sneakers.clear!
      logger = Logger.new(STDOUT)
      logger.level = Logger::ERROR
      Sneakers.configure(log: logger)
      @expected_routing_key = 'fresh_prince'
      @expected_msg = { of: 'bel air' }
      @expected_default_opts = Sneakers::CONFIG
      mock_exchange = MiniTest::Mock.new
      mock_exchange.expect(:publish, nil, [String, Hash])
      mock_channel = MiniTest::Mock.new
      mock_channel.expect(:exchange, mock_exchange, [String, Hash])
      @mock_bunny = MiniTest::Mock.new
      mock_bunny.expect(:start, nil)
      mock_bunny.expect(:create_channel, mock_channel)
    end

    describe 'when amqp_publish is not set' do
      it 'must use the default amqp for the Bunny connection' do
        mock_bunny_new = MiniTest::Mock.new
        mock_bunny_new.expect(
          :call,
          mock_bunny,
          [
            @expected_default_opts[:amqp],
            { heartbeat: @expected_default_opts[:heartbeat], vhost: @expected_default_opts[:vhost] }
          ]
        )
        Bunny.stub :new, mock_bunny_new do
          LaGear::Publisher.new.publish(@expected_msg, to_queue: @expected_routing_key)
        end
        mock_bunny_new.verify
      end
    end

    describe 'when amqp_publish is set' do
      before do
        @opts = { amqp_publish: 'amqp_publish_uri' }
      end

      it 'must use the amqp_publish_uri for the Bunny connection' do
        mock_bunny_new = MiniTest::Mock.new
        mock_bunny_new.expect(
          :call,
          mock_bunny,
          [
            @opts[:amqp_publish],
            { heartbeat: @expected_default_opts[:heartbeat], vhost: @expected_default_opts[:vhost] }
          ]
        )
        Bunny.stub :new, mock_bunny_new do
          LaGear::Publisher.new(@opts).publish(@expected_msg, to_queue: @expected_routing_key)
        end
        mock_bunny_new.verify
      end
    end

    it 'must use JSON serialization for message' do
      mock_exchange = MiniTest::Mock.new
      mock_exchange.expect(:publish, nil, [@expected_msg.to_json, Hash])
      mock_channel = MiniTest::Mock.new
      mock_channel.expect(:exchange, mock_exchange, [String, Hash])
      mock_bunny = MiniTest::Mock.new
      mock_bunny.expect(:start, nil)
      mock_bunny.expect(:create_channel, mock_channel)
      mock_bunny_new = MiniTest::Mock.new
      mock_bunny_new.expect(:call, mock_bunny, [String, Hash])
      Bunny.stub :new, mock_bunny_new do
        LaGear::Publisher.new.publish(@expected_msg, to_queue: @expected_routing_key)
      end
      mock_exchange.verify
    end
  end

  describe 'when serialize is overriden to be a no-op' do
    class PumpItUpPublisher < LaGear::Publisher
      def self.serialize(msg)
        msg
      end
    end

    # These are just tweaked tests from sneakers
    describe '#publish' do
      before do
        Sneakers.clear!
        Sneakers.configure(log: 'sneakers.log')
      end

      it 'should publish a message to an exchange' do
        xchg = Object.new
        xchg.expects(:publish).with('test msg', routing_key: 'downloads')

        p = PumpItUpPublisher.new
        p.instance_variable_set(:@exchange, xchg)

        p.stubs(:ensure_connection!)
        p.publish('test msg', to_queue: 'downloads')
      end

      it 'should publish with the persistence specified' do
        xchg = Object.new
        xchg.expects(:publish).with('test msg', routing_key: 'downloads', persistence: true)

        p = PumpItUpPublisher.new
        p.instance_variable_set(:@exchange, xchg)

        p.stubs(:ensure_connection!)
        p.publish('test msg', to_queue: 'downloads', persistence: true)
      end

      it 'should publish with arbitrary metadata specified' do
        xchg = Object.new
        xchg.expects(:publish).with('test msg', routing_key: 'downloads', expiration: 1, headers: { foo: 'bar' })

        p = PumpItUpPublisher.new
        p.instance_variable_set(:@exchange, xchg)

        p.stubs(:ensure_connection!)
        p.publish('test msg', to_queue: 'downloads', expiration: 1, headers: { foo: 'bar' })
      end

      it 'should not reconnect if already connected' do
        xchg = Object.new
        xchg.expects(:publish).with('test msg', routing_key: 'downloads')

        p = PumpItUpPublisher.new
        p.instance_variable_set(:@exchange, xchg)

        p.stubs(:connected?).returns(true)
        p.expects(:ensure_connection!).never

        p.publish('test msg', to_queue: 'downloads')
      end

      it 'should connect to rabbitmq configured on Sneakers.configure' do
        skip 'need to fix'
        logger = Logger.new('/dev/null')
        Sneakers.configure(
          amqp: 'amqp://someuser:somepassword@somehost:5672',
          heartbeat: 1, exchange: 'another_exchange',
          exchange_type: :topic,
          log: logger,
          durable: false)

        channel = Object.new
        channel.expects(:exchange).with('another_exchange', type: :topic, durable: false) do
          Object.new.expects(:publish).with('test msg', routing_key: 'downloads')
        end

        bunny = Object.new
        bunny.expects(:start)
        bunny.stubs(:create_channel).returns(channel)

        Bunny.expects(:new).with('amqp://someuser:somepassword@somehost:5672', heartbeat: 1, vhost: '/', logger: logger).returns bunny

        p = PumpItUpPublisher.new

        p.publish('test msg', to_queue: 'downloads')
      end
    end
  end
end
