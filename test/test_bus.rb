require_relative 'helper'

class BoKnow
  def self.perform_async(*_); end
  def self.perform_in(_i, *_); end
end

class BoKnow::V001
  def self.perform_async(*_); end
  def self.perform_in(_i, *_); end
end

class BoKnow::CrossTrainer
  def self.perform_async(*_); end
  def self.perform_in(_i, *_); end
end

class TestBus < LaGear::Test
  describe 'when invoking bus methods' do
    before do
      @base_routing_key = BoKnow.name.underscore
      @expected_msg = { baseball: true, football: true }
      @suffix = 'cross_trainer'
      @version = '001'
      $publisher = nil
    end

    describe '#publish' do
      before do
        @bus_method = :publish
        @sidekiq_delay_method = :sidekiq_delay
      end

      describe 'when version and suffix are not specified' do
        before do
          @la_gear_opts = {}
          @expected_routing_key = @base_routing_key
          @local_worker = BoKnow
        end

        it 'must invoke DelayablePublisher.sidekiq_delay' do
          must_invoke_delayable_publisher_sidekiq_delay
        end

        it 'must invoke DelayablePublisher.publish' do
          must_invoke_delayable_publisher_publish
        end

        describe 'when $publisher not set' do
          it 'must invoke LaGear::Publisher#publish' do
            must_invoke_la_gear_publisher_publish
          end
        end

        describe 'when $publisher set' do
          after do
            $publisher = nil
          end

          it 'must invoke $publisher.with' do
            must_invoke_publisher_with
          end

          it 'must invoke $publisher.with must invoke publisher.publish' do
            must_invoke_publisher_with_must_invoke_publisher_publish
          end
        end
      end

      describe 'when version and suffix are blank' do
        before do
          @la_gear_opts = { version: '', suffix: '' }
          @expected_routing_key = @base_routing_key
          @local_worker = BoKnow
        end

        it 'must invoke DelayablePublisher.sidekiq_delay' do
          must_invoke_delayable_publisher_sidekiq_delay
        end

        it 'must invoke DelayablePublisher.publish' do
          must_invoke_delayable_publisher_publish
        end

        describe 'when $publisher not set' do
          it 'must invoke LaGear::Publisher#publish' do
            must_invoke_la_gear_publisher_publish
          end
        end

        describe 'when $publisher set' do
          after do
            $publisher = nil
          end

          it 'must invoke $publisher.with' do
            must_invoke_publisher_with
          end

          it 'must invoke $publisher.with must invoke publisher.publish' do
            must_invoke_publisher_with_must_invoke_publisher_publish
          end
        end
      end

      describe 'when version is specified' do
        before do
          @la_gear_opts = { version: @version }
          @expected_routing_key = "#{@base_routing_key}.v#{@version}"
          @local_worker = BoKnow::V001
        end

        it 'must invoke DelayablePublisher.sidekiq_delay' do
          must_invoke_delayable_publisher_sidekiq_delay
        end

        it 'must invoke DelayablePublisher.publish' do
          must_invoke_delayable_publisher_publish
        end

        describe 'when $publisher not set' do
          it 'must invoke LaGear::Publisher#publish' do
            must_invoke_la_gear_publisher_publish
          end
        end

        describe 'when $publisher set' do
          after do
            $publisher = nil
          end

          it 'must invoke $publisher.with' do
            must_invoke_publisher_with
          end

          it 'must invoke $publisher.with must invoke publisher.publish' do
            must_invoke_publisher_with_must_invoke_publisher_publish
          end
        end
      end

      describe 'when suffix is specified' do
        before do
          @la_gear_opts = { suffix: @suffix }
          @expected_routing_key = "#{@base_routing_key}.#{@suffix}"
          @local_worker = BoKnow::CrossTrainer
        end

        it 'must invoke DelayablePublisher.sidekiq_delay' do
          must_invoke_delayable_publisher_sidekiq_delay
        end

        it 'must invoke DelayablePublisher.publish' do
          must_invoke_delayable_publisher_publish
        end

        describe 'when $publisher not set' do
          it 'must invoke LaGear::Publisher#publish' do
            must_invoke_la_gear_publisher_publish
          end
        end

        describe 'when $publisher set' do
          after do
            $publisher = nil
          end

          it 'must invoke $publisher.with' do
            must_invoke_publisher_with
          end

          it 'must invoke $publisher.with must invoke publisher.publish' do
            must_invoke_publisher_with_must_invoke_publisher_publish
          end
        end
      end

      describe 'when version and suffix are specified' do
        before do
          @la_gear_opts = { version: @version, suffix: @suffix }
          @expected_routing_key = "#{@base_routing_key}.v#{@version}"
          @local_worker = BoKnow::V001
        end

        it 'must invoke DelayablePublisher.sidekiq_delay' do
          must_invoke_delayable_publisher_sidekiq_delay
        end

        it 'must invoke DelayablePublisher.publish' do
          must_invoke_delayable_publisher_publish
        end

        describe 'when $publisher not set' do
          it 'must invoke LaGear::Publisher#publish' do
            must_invoke_la_gear_publisher_publish
          end
        end

        describe 'when $publisher set' do
          after do
            $publisher = nil
          end

          it 'must invoke $publisher.with' do
            must_invoke_publisher_with
          end

          it 'must invoke $publisher.with must invoke publisher.publish' do
            must_invoke_publisher_with_must_invoke_publisher_publish
          end
        end

        describe 'when method is called more than once' do
          it 'does not modify the parameters' do
            does_not_modify_parameters
          end
        end
      end
    end

    describe '#publish_in' do
      before do
        @bus_method = :publish_in
        @sidekiq_delay_method = :sidekiq_delay_for
        @expected_interval = 2.days
      end

      describe 'when version and suffix are not specified' do
        before do
          @la_gear_opts = {}
          @expected_routing_key = @base_routing_key
          @local_worker = BoKnow
        end

        it 'must invoke DelayablePublisher.sidekiq_delay' do
          must_invoke_delayable_publisher_sidekiq_delay
        end

        it 'must invoke DelayablePublisher.publish' do
          must_invoke_delayable_publisher_publish
        end

        describe 'when $publisher not set' do
          it 'must invoke LaGear::Publisher#publish' do
            must_invoke_la_gear_publisher_publish
          end
        end

        describe 'when $publisher set' do
          after do
            $publisher = nil
          end

          it 'must invoke $publisher.with' do
            must_invoke_publisher_with
          end

          it 'must invoke $publisher.with must invoke publisher.publish' do
            must_invoke_publisher_with_must_invoke_publisher_publish
          end
        end
      end

      describe 'when version and suffix are blank' do
        before do
          @la_gear_opts = { version: '', suffix: '' }
          @expected_routing_key = @base_routing_key
          @local_worker = BoKnow
        end

        it 'must invoke DelayablePublisher.sidekiq_delay' do
          must_invoke_delayable_publisher_sidekiq_delay
        end

        it 'must invoke DelayablePublisher.publish' do
          must_invoke_delayable_publisher_publish
        end

        describe 'when $publisher not set' do
          it 'must invoke LaGear::Publisher#publish' do
            must_invoke_la_gear_publisher_publish
          end
        end

        describe 'when $publisher set' do
          after do
            $publisher = nil
          end

          it 'must invoke $publisher.with' do
            must_invoke_publisher_with
          end

          it 'must invoke $publisher.with must invoke publisher.publish' do
            must_invoke_publisher_with_must_invoke_publisher_publish
          end
        end
      end

      describe 'when version is specified' do
        before do
          @la_gear_opts = { version: @version }
          @expected_routing_key = "#{@base_routing_key}.v#{@version}"
          @local_worker = BoKnow::V001
        end

        it 'must invoke DelayablePublisher.sidekiq_delay' do
          must_invoke_delayable_publisher_sidekiq_delay
        end

        it 'must invoke DelayablePublisher.publish' do
          must_invoke_delayable_publisher_publish
        end

        describe 'when $publisher not set' do
          it 'must invoke LaGear::Publisher#publish' do
            must_invoke_la_gear_publisher_publish
          end
        end

        describe 'when $publisher set' do
          after do
            $publisher = nil
          end

          it 'must invoke $publisher.with' do
            must_invoke_publisher_with
          end

          it 'must invoke $publisher.with must invoke publisher.publish' do
            must_invoke_publisher_with_must_invoke_publisher_publish
          end
        end
      end

      describe 'when suffix is specified' do
        before do
          @la_gear_opts = { suffix: @suffix }
          @expected_routing_key = "#{@base_routing_key}.#{@suffix}"
          @local_worker = BoKnow::CrossTrainer
        end

        it 'must invoke DelayablePublisher.sidekiq_delay' do
          must_invoke_delayable_publisher_sidekiq_delay
        end

        it 'must invoke DelayablePublisher.publish' do
          must_invoke_delayable_publisher_publish
        end

        describe 'when $publisher not set' do
          it 'must invoke LaGear::Publisher#publish' do
            must_invoke_la_gear_publisher_publish
          end
        end

        describe 'when $publisher set' do
          after do
            $publisher = nil
          end

          it 'must invoke $publisher.with' do
            must_invoke_publisher_with
          end

          it 'must invoke $publisher.with must invoke publisher.publish' do
            must_invoke_publisher_with_must_invoke_publisher_publish
          end
        end
      end

      describe 'when version and suffix are specified' do
        before do
          @la_gear_opts = { version: @version, suffix: @suffix }
          @expected_routing_key = "#{@base_routing_key}.v#{@version}"
          @local_worker = BoKnow::V001
        end

        it 'must invoke DelayablePublisher.sidekiq_delay' do
          must_invoke_delayable_publisher_sidekiq_delay
        end

        it 'must invoke DelayablePublisher.publish' do
          must_invoke_delayable_publisher_publish
        end

        describe 'when $publisher not set' do
          it 'must invoke LaGear::Publisher#publish' do
            must_invoke_la_gear_publisher_publish
          end
        end

        describe 'when $publisher set' do
          after do
            $publisher = nil
          end

          it 'must invoke $publisher.with' do
            must_invoke_publisher_with
          end

          it 'must invoke $publisher.with must invoke publisher.publish' do
            must_invoke_publisher_with_must_invoke_publisher_publish
          end
        end

        describe 'when method is called more than once' do
          it 'does not modify the parameters' do
            does_not_modify_parameters
          end
        end
      end
    end

    describe '#publish_at' do
      before do
        @bus_method = :publish_at
        @sidekiq_delay_method = :sidekiq_delay_until
        @expected_timestamp = 2.days.ago
      end

      describe 'when version and suffix are not specified' do
        before do
          @la_gear_opts = {}
          @expected_routing_key = @base_routing_key
          @local_worker = BoKnow
        end

        it 'must invoke DelayablePublisher.sidekiq_delay' do
          must_invoke_delayable_publisher_sidekiq_delay
        end

        it 'must invoke DelayablePublisher.publish' do
          must_invoke_delayable_publisher_publish
        end

        describe 'when $publisher not set' do
          it 'must invoke LaGear::Publisher#publish' do
            must_invoke_la_gear_publisher_publish
          end
        end

        describe 'when $publisher set' do
          after do
            $publisher = nil
          end

          it 'must invoke $publisher.with' do
            must_invoke_publisher_with
          end

          it 'must invoke $publisher.with must invoke publisher.publish' do
            must_invoke_publisher_with_must_invoke_publisher_publish
          end
        end
      end

      describe 'when version and suffix are blank' do
        before do
          @la_gear_opts = { version: '', suffix: '' }
          @expected_routing_key = @base_routing_key
          @local_worker = BoKnow
        end

        it 'must invoke DelayablePublisher.sidekiq_delay' do
          must_invoke_delayable_publisher_sidekiq_delay
        end

        it 'must invoke DelayablePublisher.publish' do
          must_invoke_delayable_publisher_publish
        end

        describe 'when $publisher not set' do
          it 'must invoke LaGear::Publisher#publish' do
            must_invoke_la_gear_publisher_publish
          end
        end

        describe 'when $publisher set' do
          after do
            $publisher = nil
          end

          it 'must invoke $publisher.with' do
            must_invoke_publisher_with
          end

          it 'must invoke $publisher.with must invoke publisher.publish' do
            must_invoke_publisher_with_must_invoke_publisher_publish
          end
        end
      end

      describe 'when version is specified' do
        before do
          @la_gear_opts = { version: @version }
          @expected_routing_key = "#{@base_routing_key}.v#{@version}"
          @local_worker = BoKnow::V001
        end

        it 'must invoke DelayablePublisher.sidekiq_delay' do
          must_invoke_delayable_publisher_sidekiq_delay
        end

        it 'must invoke DelayablePublisher.publish' do
          must_invoke_delayable_publisher_publish
        end

        describe 'when $publisher not set' do
          it 'must invoke LaGear::Publisher#publish' do
            must_invoke_la_gear_publisher_publish
          end
        end

        describe 'when $publisher set' do
          after do
            $publisher = nil
          end

          it 'must invoke $publisher.with' do
            must_invoke_publisher_with
          end

          it 'must invoke $publisher.with must invoke publisher.publish' do
            must_invoke_publisher_with_must_invoke_publisher_publish
          end
        end
      end

      describe 'when suffix is specified' do
        before do
          @la_gear_opts = { suffix: @suffix }
          @expected_routing_key = "#{@base_routing_key}.#{@suffix}"
          @local_worker = BoKnow::CrossTrainer
        end

        it 'must invoke DelayablePublisher.sidekiq_delay' do
          must_invoke_delayable_publisher_sidekiq_delay
        end

        it 'must invoke DelayablePublisher.publish' do
          must_invoke_delayable_publisher_publish
        end

        describe 'when $publisher not set' do
          it 'must invoke LaGear::Publisher#publish' do
            must_invoke_la_gear_publisher_publish
          end
        end

        describe 'when $publisher set' do
          after do
            $publisher = nil
          end

          it 'must invoke $publisher.with' do
            must_invoke_publisher_with
          end

          it 'must invoke $publisher.with must invoke publisher.publish' do
            must_invoke_publisher_with_must_invoke_publisher_publish
          end
        end
      end

      describe 'when version and suffix are specified' do
        before do
          @la_gear_opts = { version: @version, suffix: @suffix }
          @expected_routing_key = "#{@base_routing_key}.v#{@version}"
          @local_worker = BoKnow::V001
        end

        it 'must invoke DelayablePublisher.sidekiq_delay' do
          must_invoke_delayable_publisher_sidekiq_delay
        end

        it 'must invoke DelayablePublisher.publish' do
          must_invoke_delayable_publisher_publish
        end

        describe 'when $publisher not set' do
          it 'must invoke LaGear::Publisher#publish' do
            must_invoke_la_gear_publisher_publish
          end
        end

        describe 'when $publisher set' do
          after do
            $publisher = nil
          end

          it 'must invoke $publisher.with' do
            must_invoke_publisher_with
          end

          it 'must invoke $publisher.with must invoke publisher.publish' do
            must_invoke_publisher_with_must_invoke_publisher_publish
          end
        end

        describe 'when method is called more than once' do
          it 'does not modify the parameters' do
            does_not_modify_parameters
          end
        end
      end
    end

    describe '#publish_local' do
      before do
        @bus_method = :publish_local
        @perform_method = :perform_async
      end

      describe 'when version and suffix are not specified' do
        before do
          @la_gear_opts = {}
          @expected_routing_key = @base_routing_key
          @local_worker = BoKnow
        end

        it 'must invoke perform_async on the constantized routing_key' do
          must_invoke_perform_method_on_the_constantized_routing_key
        end
      end

      describe 'when version and suffix are blank' do
        before do
          @la_gear_opts = { version: '', suffix: '' }
          @expected_routing_key = @base_routing_key
          @local_worker = BoKnow
        end

        it 'must invoke perform_async on the constantized routing_key' do
          must_invoke_perform_method_on_the_constantized_routing_key
        end
      end

      describe 'when version is specified' do
        before do
          @la_gear_opts = { version: @version }
          @expected_routing_key = "#{@base_routing_key}.v#{@version}"
          @local_worker = BoKnow::V001
        end

        it 'must invoke perform_async on the constantized routing_key' do
          must_invoke_perform_method_on_the_constantized_routing_key
        end
      end

      describe 'when suffix is specified' do
        before do
          @la_gear_opts = { suffix: @suffix }
          @expected_routing_key = "#{@base_routing_key}.v#{@version}"
          @local_worker = BoKnow::CrossTrainer
        end

        it 'must invoke perform_async on the constantized routing_key' do
          must_invoke_perform_method_on_the_constantized_routing_key
        end
      end

      describe 'when version and suffix are specified' do
        before do
          @la_gear_opts = { version: @version, suffix: @suffix }
          @expected_routing_key = "#{@base_routing_key}.v#{@version}"
          @local_worker = BoKnow::V001
        end

        it 'must invoke perform_async on the constantized routing_key' do
          must_invoke_perform_method_on_the_constantized_routing_key
        end

        describe 'when method is called more than once' do
          it 'does not modify the parameters' do
            does_not_modify_parameters
          end
        end
      end
    end

    describe '#publish_local_in' do
      before do
        @bus_method = :publish_local_in
        @perform_method = :perform_in
        @expected_interval = 10.minutes
      end

      describe 'when version and suffix are not specified' do
        before do
          @la_gear_opts = {}
          @expected_routing_key = @base_routing_key
          @local_worker = BoKnow
        end

        it 'must invoke perform_async on the constantized routing_key' do
          must_invoke_perform_method_on_the_constantized_routing_key
        end
      end

      describe 'when version and suffix are blank' do
        before do
          @la_gear_opts = { version: '', suffix: '' }
          @expected_routing_key = @base_routing_key
          @local_worker = BoKnow
        end

        it 'must invoke perform_async on the constantized routing_key' do
          must_invoke_perform_method_on_the_constantized_routing_key
        end
      end

      describe 'when version is specified' do
        before do
          @la_gear_opts = { version: @version }
          @expected_routing_key = "#{@base_routing_key}.v#{@version}"
          @local_worker = BoKnow::V001
        end

        it 'must invoke perform_async on the constantized routing_key' do
          must_invoke_perform_method_on_the_constantized_routing_key
        end
      end

      describe 'when suffix is specified' do
        before do
          @la_gear_opts = { suffix: @suffix }
          @expected_routing_key = "#{@base_routing_key}.v#{@version}"
          @local_worker = BoKnow::CrossTrainer
        end

        it 'must invoke perform_async on the constantized routing_key' do
          must_invoke_perform_method_on_the_constantized_routing_key
        end
      end

      describe 'when version and suffix are specified' do
        before do
          @la_gear_opts = { version: @version, suffix: @suffix }
          @expected_routing_key = "#{@base_routing_key}.v#{@version}"
          @local_worker = BoKnow::V001
        end

        it 'must invoke perform_async on the constantized routing_key' do
          must_invoke_perform_method_on_the_constantized_routing_key
        end

        describe 'when method is called more than once' do
          it 'does not modify the parameters' do
            does_not_modify_parameters
          end
        end
      end
    end

    private

    def does_not_modify_parameters
      expected_opts = @la_gear_opts.clone
      args = [@base_routing_key, @expected_msg, @la_gear_opts]
      args.unshift(@expected_timestamp) if defined?(@expected_timestamp)
      if defined?(@expected_interval)
        args.push(@expected_interval) if @bus_method == :publish_local_in
        args.unshift(@expected_interval) if @bus_method == :publish_in
      end
      LaGear::Bus.public_send(@bus_method, *args)
      LaGear::Bus.public_send(@bus_method, *args)
      @la_gear_opts.must_equal(expected_opts)
    end

    def must_invoke_delayable_publisher_sidekiq_delay
      expected_args = [{}]
      expected_args.unshift(@expected_interval) if defined?(@expected_interval)
      expected_args.unshift(@expected_timestamp) if defined?(@expected_timestamp)
      mock = MiniTest::Mock.new
      mock.expect(:call, LaGear::Bus::DelayablePublisher, expected_args)
      LaGear::Bus::DelayablePublisher.stub @sidekiq_delay_method, mock do
        LaGear::Bus::DelayablePublisher.stub :publish, nil do
          input_args = [@base_routing_key, @expected_msg, @la_gear_opts]
          input_args.unshift(@expected_timestamp) if defined?(@expected_timestamp)
          if defined?(@expected_interval)
            input_args.push(@expected_interval) if @bus_method == :publish_local_in
            input_args.unshift(@expected_interval) if @bus_method == :publish_in
          end
          LaGear::Bus.public_send(@bus_method, *input_args)
        end
      end
      mock.verify
    end

    def must_invoke_delayable_publisher_publish
      mock = MiniTest::Mock.new
      mock.expect(:call, nil, [@expected_routing_key, @expected_msg, {}])
      LaGear::Bus::DelayablePublisher.stub @sidekiq_delay_method, LaGear::Bus::DelayablePublisher do
        LaGear::Bus::DelayablePublisher.stub :publish, mock do
          args = [@base_routing_key, @expected_msg, @la_gear_opts]

          args.unshift(@expected_timestamp) if defined?(@expected_timestamp)
          if defined?(@expected_interval)
            args.push(@expected_interval) if @bus_method == :publish_local_in
            args.unshift(@expected_interval) if @bus_method == :publish_in
          end

          LaGear::Bus.send(@bus_method, *args)
        end
      end
      mock.verify
    end

    def must_invoke_la_gear_publisher_publish
      mock = MiniTest::Mock.new
      mock.expect(:publish, nil, [@expected_msg, { to_queue: @expected_routing_key }])
      LaGear::Bus::DelayablePublisher.stub @sidekiq_delay_method, LaGear::Bus::DelayablePublisher do
        LaGear::Publisher.stub :new, mock do
          args = [@base_routing_key, @expected_msg, @la_gear_opts]

          args.unshift(@expected_timestamp) if defined?(@expected_timestamp)
          if defined?(@expected_interval)
            args.push(@expected_interval) if @bus_method == :publish_local_in
            args.unshift(@expected_interval) if @bus_method == :publish_in
          end

          LaGear::Bus.send(@bus_method, *args)
        end
      end
      mock.verify
    end

    def must_invoke_publisher_with
      $publisher = MiniTest::Mock.new
      $publisher.expect(:with, nil)
      LaGear::Bus::DelayablePublisher.stub @sidekiq_delay_method, LaGear::Bus::DelayablePublisher do
        args = [@base_routing_key, @expected_msg, @la_gear_opts]

        args.unshift(@expected_timestamp) if defined?(@expected_timestamp)
        if defined?(@expected_interval)
          args.push(@expected_interval) if @bus_method == :publish_local_in
          args.unshift(@expected_interval) if @bus_method == :publish_in
        end

        LaGear::Bus.send(@bus_method, *args)
      end
      $publisher.verify
    end

    def must_invoke_publisher_with_must_invoke_publisher_publish
      mock = MiniTest::Mock.new
      $publisher = ConnectionPool.new { mock }
      mock.expect(:publish, nil, [@expected_msg, { to_queue: @expected_routing_key }])
      LaGear::Bus::DelayablePublisher.stub @sidekiq_delay_method, LaGear::Bus::DelayablePublisher do
        args = [@base_routing_key, @expected_msg, @la_gear_opts]

        args.unshift(@expected_timestamp) if defined?(@expected_timestamp)
        if defined?(@expected_interval)
          args.push(@expected_interval) if @bus_method == :publish_local_in
          args.unshift(@expected_interval) if @bus_method == :publish_in
        end

        LaGear::Bus.send(@bus_method, *args)
      end
      mock.verify
    end

    def must_invoke_perform_method_on_the_constantized_routing_key
      expected_args = @expected_msg.values
      expected_args.unshift(@expected_interval) if defined?(@expected_interval)
      expected_args.unshift(@expected_timestamp) if defined?(@expected_timestamp)
      mock = MiniTest::Mock.new
      mock.expect(:call, nil, expected_args)
      @local_worker.stub @perform_method, mock do
        input_args = [@base_routing_key, @expected_msg, @la_gear_opts]

        input_args.unshift(@expected_timestamp) if defined?(@expected_timestamp)
        if defined?(@expected_interval)
          input_args.push(@expected_interval) if @bus_method == :publish_local_in
          input_args.unshift(@expected_interval) if @bus_method == :publish_in
        end

        LaGear::Bus.send(@bus_method, *input_args)
      end
      mock.verify
    end
  end
end
