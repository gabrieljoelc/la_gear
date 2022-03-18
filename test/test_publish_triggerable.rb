require_relative 'helper'
require 'la_gear/active_record/publish_triggerable'

class TestPublishTriggerable < LaGear::Spec
  before do
    @base_routing_key = 'bo_knows'
    @expected_method_name = "publish_#{@base_routing_key}"
    @suffix = 'cross_trainer'
    @version = '001'
    @model_klass = Class.new do
      extend LaGear::ActiveRecord::PublishTriggerable

      def self.after_commit(*_); end

      2.times do |index|
        define_method "attr#{index + 1}" do
          index + 1
        end
      end
    end
  end

  describe '#publish_after_commit' do
    before do
      @trigger_method = 'publish_after_commit'
      @la_gear_method = :publish
    end

    describe 'no version or suffix specified' do
      before do
        @expected_routing_key = @base_routing_key
        @opts = {}
      end

      it 'must define a publish_bo_knows method' do
        must_define_magic_method
      end

      it 'must pass new publish method name to after_commit' do
        must_pass_new_publish_method_name_to_after_commit
      end

      it 'must invoke Bus.publish with routing key and message' do
        must_call_publish_on_bus
      end
    end

    describe 'empty version and suffix specified' do
      before do
        @expected_routing_key = @base_routing_key
        @opts = { suffix: '', version: '' }
      end

      it 'must define a publish_bo_knows method' do
        must_define_magic_method
      end

      it 'must pass new publish method name to after_commit' do
        must_pass_new_publish_method_name_to_after_commit
      end

      it 'must invoke Bus.publish with routing key and message' do
        must_call_publish_on_bus
      end
    end

    describe 'suffix specified' do
      before do
        @expected_routing_key = @base_routing_key
        @opts = { suffix: @suffix }
      end

      it 'must define a publish_bo_knows method' do
        must_define_magic_method
      end

      it 'must pass new publish method name to after_commit' do
        must_pass_new_publish_method_name_to_after_commit
      end

      it 'must invoke Bus.publish with routing key and message' do
        must_call_publish_on_bus
      end
    end

    describe 'version specified' do
      before do
        @expected_routing_key = @base_routing_key
        @opts = { version: @version }
      end

      it 'must define a publish_bo_knows method' do
        must_define_magic_method
      end

      it 'must pass new publish method name to after_commit' do
        must_pass_new_publish_method_name_to_after_commit
      end

      it 'must invoke Bus.publish with routing key and message' do
        must_call_publish_on_bus
      end
    end

    describe 'version and suffix specified' do
      before do
        @expected_routing_key = @base_routing_key
        @opts = { version: @version, suffix: @suffix }
      end

      it 'must define a publish_bo_knows method' do
        must_define_magic_method
      end

      it 'must pass new publish method name to after_commit' do
        must_pass_new_publish_method_name_to_after_commit
      end

      it 'must invoke Bus.publish with routing key and message' do
        must_call_publish_on_bus
      end
    end
  end

  describe '#send_after_commit' do
    before do
      @trigger_method = 'send_after_commit'
      @la_gear_method = :publish_local
    end

    describe 'no version or suffix specified' do
      before do
        @expected_routing_key = @base_routing_key
        @opts = {}
      end

      it 'must define a publish_bo_knows method' do
        must_define_magic_method
      end

      it 'must pass new publish method name to after_commit' do
        must_pass_new_publish_method_name_to_after_commit
      end

      it 'must invoke Bus.publish with routing key and message' do
        must_call_publish_on_bus
      end
    end

    describe 'empty version and suffix specified' do
      before do
        @expected_routing_key = @base_routing_key
        @opts = { suffix: '', version: '' }
      end

      it 'must define a publish_bo_knows method' do
        must_define_magic_method
      end

      it 'must pass new publish method name to after_commit' do
        must_pass_new_publish_method_name_to_after_commit
      end

      it 'must invoke Bus.publish with routing key and message' do
        must_call_publish_on_bus
      end
    end

    describe 'suffix specified' do
      before do
        @expected_routing_key = @base_routing_key
        @opts = { suffix: @suffix }
      end

      it 'must define a publish_bo_knows method' do
        must_define_magic_method
      end

      it 'must pass new publish method name to after_commit' do
        must_pass_new_publish_method_name_to_after_commit
      end

      it 'must invoke Bus.publish with routing key and message' do
        must_call_publish_on_bus
      end
    end

    describe 'version specified' do
      before do
        @expected_routing_key = @base_routing_key
        @opts = { version: @version }
      end

      it 'must define a publish_bo_knows method' do
        must_define_magic_method
      end

      it 'must pass new publish method name to after_commit' do
        must_pass_new_publish_method_name_to_after_commit
      end

      it 'must invoke Bus.publish with routing key and message' do
        must_call_publish_on_bus
      end
    end

    describe 'version and suffix specified' do
      before do
        @expected_routing_key = @base_routing_key
        @opts = { version: @version, suffix: @suffix }
      end

      it 'must define a publish_bo_knows method' do
        must_define_magic_method
      end

      it 'must pass new publish method name to after_commit' do
        must_pass_new_publish_method_name_to_after_commit
      end

      it 'must invoke Bus.publish with routing key and message' do
        must_call_publish_on_bus
      end
    end
  end

  describe '#send_in_after_commit' do
    before do
      @trigger_method = 'send_in_after_commit'
      @la_gear_method = :publish_local_in
      @interval = 10.minutes
    end

    describe 'no version or suffix specified' do
      before do
        @expected_routing_key = @base_routing_key
        @opts = {}
      end

      it 'must define a publish_bo_knows method' do
        must_define_magic_method
      end

      it 'must pass new publish method name to after_commit' do
        must_pass_new_publish_method_name_to_after_commit
      end

      it 'must invoke Bus.publish with routing key and message' do
        must_call_publish_on_bus
      end
    end

    describe 'empty version and suffix specified' do
      before do
        @expected_routing_key = @base_routing_key
        @opts = { suffix: '', version: '' }
      end

      it 'must define a publish_bo_knows method' do
        must_define_magic_method
      end

      it 'must pass new publish method name to after_commit' do
        must_pass_new_publish_method_name_to_after_commit
      end

      it 'must invoke Bus.publish with routing key and message' do
        must_call_publish_on_bus
      end
    end

    describe 'suffix specified' do
      before do
        @expected_routing_key = @base_routing_key
        @opts = { suffix: @suffix }
      end

      it 'must define a publish_bo_knows method' do
        must_define_magic_method
      end

      it 'must pass new publish method name to after_commit' do
        must_pass_new_publish_method_name_to_after_commit
      end

      it 'must invoke Bus.publish with routing key and message' do
        must_call_publish_on_bus
      end
    end

    describe 'version specified' do
      before do
        @expected_routing_key = @base_routing_key
        @opts = { version: @version }
      end

      it 'must define a publish_bo_knows method' do
        must_define_magic_method
      end

      it 'must pass new publish method name to after_commit' do
        must_pass_new_publish_method_name_to_after_commit
      end

      it 'must invoke Bus.publish with routing key and message' do
        must_call_publish_on_bus
      end
    end

    describe 'version and suffix specified' do
      before do
        @expected_routing_key = @base_routing_key
        @opts = { version: @version, suffix: @suffix }
      end

      it 'must define a publish_bo_knows method' do
        must_define_magic_method
      end

      it 'must pass new publish method name to after_commit' do
        must_pass_new_publish_method_name_to_after_commit
      end

      it 'must invoke Bus.publish with routing key and message' do
        must_call_publish_on_bus
      end
    end
  end

  private

  def must_define_magic_method
    args = [@base_routing_key, @opts.clone]
    args.push(@interval) if defined?(@interval)

    @model_klass.public_send(@trigger_method, *args) {}
    @model_klass.new.must_respond_to @expected_method_name
  end

  def must_pass_new_publish_method_name_to_after_commit
    mock = MiniTest::Mock.new
    mock.expect(:call, nil, [@expected_method_name.to_sym, {}])
    @model_klass.stub :after_commit, mock do
      args = [@base_routing_key, @opts.clone]
      args.push(@interval) if defined?(@interval)

      @model_klass.public_send(@trigger_method, *args) {}
    end
    mock.verify
  end

  def must_call_publish_on_bus
    args1 = [@base_routing_key, @opts.clone]
    args1.push(@interval) if defined?(@interval)
    @model_klass.public_send(@trigger_method, *args1) do |model|
      { key1: model.attr1, key2: model.attr2 }
    end
    mock = MiniTest::Mock.new
    model = @model_klass.new
    expected_msg = { key1: model.attr1, key2: model.attr2 }

    args2 = [@expected_routing_key, expected_msg, @opts.clone]
    args2.push(@interval) if defined?(@interval)
    mock.expect(:call, nil, args2)
    LaGear::Bus.stub @la_gear_method, mock do
      model.send(@expected_method_name)
    end
  end
end
