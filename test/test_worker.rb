require_relative 'helper'

Sneakers::CONFIG[:app_name] = 'bo_knows'
Sneakers::CONFIG[:exchange] = 'football'

class PumpItUp
  include LaGear::Worker
end
module NotPogs
  class V2
    include LaGear::Worker
  end
end

module GoGo
  module PowerRangers
    class V2
      include LaGear::Worker
    end
  end
end

module SlapBraceletSender
  class V1
    include LaGear::Worker

    subscribes_to NotPogs::V2.routing_key
  end
end

class DoubleDutch
  include LaGear::Worker

  subscribes_to [PumpItUp.routing_key, NotPogs::V2.routing_key]
end

class TestWorker < LaGear::Test
  describe 'when a worker is defined and there is a custom Sneakers app_name' do
    before do
      Sneakers::CONFIG[:app_name] = 'bo_knows'
      Sneakers::CONFIG[:exchange] = 'football'
      @expected_queue_routing_key = PumpItUp.name.underscore
      @message = { arg1: 1, arg2: 2 }.to_json
    end

    it 'must have pump_it_up as the routing_key' do
      PumpItUp.routing_key.must_equal @expected_queue_routing_key
    end

    it 'must have bo_knows.pump_it_up as the default_queue_name' do
      PumpItUp.default_queue_name.must_equal "#{Sneakers::CONFIG[:app_name]}.#{@expected_queue_routing_key}"
    end

    it 'must have bo_knows.pump_it_up.retry as the retry_routing_key' do
      PumpItUp.retry_routing_key.must_equal "#{Sneakers::CONFIG[:app_name]}.#{@expected_queue_routing_key}.retry"
    end

    it 'must have default queue has with x-dead-letter-exchange of football.retry' do
      PumpItUp.default_queue_args.must_equal 'x-dead-letter-exchange' => "#{Sneakers::CONFIG[:exchange]}.retry"
    end

    describe 'when global queue_arguments are set' do
      before do
        @global_queue_args = { 'x-expires' => 60_000 }
        Sneakers::CONFIG[:global_queue_options] = @global_queue_args
      end

      after do
        Sneakers::CONFIG.delete(:global_queue_options)
      end

      it 'must include global queue_arguments' do
        PumpItUp.default_queue_opts[:queue_options]['x-expires'].must_equal 60_000
      end
    end

    it 'must have default queue options hash' do
      PumpItUp.default_queue_opts.must_equal(
        routing_key: [PumpItUp.routing_key, PumpItUp.retry_routing_key],
        queue_options: {
          arguments: PumpItUp.default_queue_args
        },
        handler_opts: {
          routing_key: PumpItUp.retry_routing_key
        }
      )
    end

    it 'must deserialize JSON' do
      PumpItUp.deserialize(@message).must_equal JSON.parse(@message)
    end

    it 'must send message values to perform_async' do
      mock = MiniTest::Mock.new
      mock.expect(:call, nil, JSON.parse(@message).values)
      PumpItUp.stub :perform_async, mock do
        PumpItUp.new.work(@message).must_equal :ack
      end
      mock.verify
    end

    describe 'when the worker is namespaced once' do
      before do
        @expected_queue_routing_key = 'not_pogs.v2'
      end

      it 'must have not_pogs.v2 as the routing_key' do
        NotPogs::V2.routing_key.must_equal @expected_queue_routing_key
      end

      it 'must have bo_knows.pump_it_up as the default_queue_name' do
        NotPogs::V2.default_queue_name.must_equal "#{Sneakers::CONFIG[:app_name]}.#{@expected_queue_routing_key}"
      end

      it 'must have bo_knows.pump_it_up.retry as the retry_routing_key' do
        NotPogs::V2.retry_routing_key.must_equal "#{Sneakers::CONFIG[:app_name]}.#{@expected_queue_routing_key}.retry"
      end

      it 'must have default queue has with x-dead-letter-exchange of football.retry' do
        NotPogs::V2.default_queue_args.must_equal 'x-dead-letter-exchange' => "#{Sneakers::CONFIG[:exchange]}.retry"
      end

      it 'must have default queue options hash' do
        NotPogs::V2.default_queue_opts.must_equal(
          routing_key: [NotPogs::V2.routing_key, NotPogs::V2.retry_routing_key],
          queue_options: {
            arguments: NotPogs::V2.default_queue_args
          },
          handler_opts: {
            routing_key: NotPogs::V2.retry_routing_key
          }
        )
      end
    end

    describe 'when the worker is namespaced twice' do
      before do
        @expected_queue_routing_key = 'go_go.power_rangers.v2'
      end

      it 'must have go_go.power_rangers.v2 as the routing_key' do
        GoGo::PowerRangers::V2.routing_key.must_equal @expected_queue_routing_key
      end

      it 'must have bo_knows.pump_it_up as the default_queue_name' do
        GoGo::PowerRangers::V2.default_queue_name.must_equal "#{Sneakers::CONFIG[:app_name]}.#{@expected_queue_routing_key}"
      end

      it 'must have bo_knows.pump_it_up.retry as the retry_routing_key' do
        GoGo::PowerRangers::V2.retry_routing_key.must_equal "#{Sneakers::CONFIG[:app_name]}.#{@expected_queue_routing_key}.retry"
      end

      it 'must have default queue has with x-dead-letter-exchange of football.retry' do
        GoGo::PowerRangers::V2.default_queue_args.must_equal 'x-dead-letter-exchange' => "#{Sneakers::CONFIG[:exchange]}.retry"
      end

      it 'must have default queue options hash' do
        GoGo::PowerRangers::V2.default_queue_opts.must_equal(
          routing_key: [GoGo::PowerRangers::V2.routing_key, GoGo::PowerRangers::V2.retry_routing_key],
          queue_options: {
            arguments: GoGo::PowerRangers::V2.default_queue_args
          },
          handler_opts: {
            routing_key: GoGo::PowerRangers::V2.retry_routing_key
          }
        )
      end
    end

    describe 'when the worker is namespaced once and invokes subscribes_to' do
      before do
        @expected_queue_routing_key = 'not_pogs.v2'
      end

      it 'must have not_pogs.v2 as the routing_key' do
        SlapBraceletSender::V1.routing_key.must_equal @expected_queue_routing_key
      end

      it 'must have bo_knows.slap_bracelet_sender.v1 as the default_queue_name' do
        SlapBraceletSender::V1.default_queue_name.must_equal "#{Sneakers::CONFIG[:app_name]}.#{SlapBraceletSender::V1.name.underscore.tr('/', '.')}"
      end

      it 'must have bo_knows.slap_bracelet_sender.v1.retry as the retry_routing_key' do
        SlapBraceletSender::V1.retry_routing_key.must_equal "#{Sneakers::CONFIG[:app_name]}.#{SlapBraceletSender::V1.name.underscore.tr('/', '.')}.retry"
      end

      it 'must have default queue has with x-dead-letter-exchange of football.retry' do
        SlapBraceletSender::V1.default_queue_args.must_equal 'x-dead-letter-exchange' => "#{Sneakers::CONFIG[:exchange]}.retry"
      end

      it 'must have default queue options hash' do
        SlapBraceletSender::V1.default_queue_opts.must_equal(
          routing_key: [SlapBraceletSender::V1.routing_key, SlapBraceletSender::V1.retry_routing_key],
          queue_options: {
            arguments: SlapBraceletSender::V1.default_queue_args
          },
          handler_opts: {
            routing_key: SlapBraceletSender::V1.retry_routing_key
          }
        )
      end
    end

    describe 'when the worker subscribes to multiple keys' do
      before do
        @expected_queue_routing_key = ['pump_it_up', 'not_pogs.v2']
      end

      it 'must have pump_it_up and not_pogs.v2 as the routing keys' do
        DoubleDutch.routing_key.must_equal @expected_queue_routing_key
      end

      it 'must have default queue options hash' do
        DoubleDutch.default_queue_opts.must_equal(
          routing_key: [PumpItUp.routing_key, NotPogs::V2.routing_key, DoubleDutch.retry_routing_key],
          queue_options: {
            arguments: DoubleDutch.default_queue_args
          },
          handler_opts: {
            routing_key: DoubleDutch.retry_routing_key
          }
        )
      end
    end
  end
end
