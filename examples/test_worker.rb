$: << File.expand_path('../lib', File.dirname(__FILE__))

require 'sneakers/runner'
require 'la_gear'
require 'la_gear/sneakers'

Sneakers.configure(
  logger: STDOUT,
  handler: LaGear::Sneakers::Handlers::ExponentialBackoff
)

# old way
class TestWorker
  include LaGear::Worker

  def perform(_); end
end

# new way
class TestWorker2
  include LaGear::Worker

  subscribes_to :test_worker

  def perform(_); end
end

# multiple keys
class TestWorker3
  include LaGear::Worker

  subscribes_to [:test_worker, :test_worker3]

  def perform(_); end
end

Sneakers.logger.level = Logger::INFO
bunny = Bunny.new
bunny.start
channel = bunny.channel
queue = channel.queue(
  TestWorker.default_queue_name,
  TestWorker.default_queue_opts.merge(durable: true, arguments: TestWorker.default_queue_args),
)
queue2 = channel.queue(
  TestWorker2.default_queue_name,
  TestWorker2.default_queue_opts.merge(durable: true, arguments: TestWorker2.default_queue_args),
)
queue3 = channel.queue(
  TestWorker3.default_queue_name,
  TestWorker3.default_queue_opts.merge(durable: true, arguments: TestWorker3.default_queue_args),
)
queue.purge
r = Sneakers::Runner.new([TestWorker, TestWorker2, TestWorker3])
pid = fork do
  r.run
end
Process.detach(pid)
LaGear::Publisher.new.publish(TestWorker.routing_key, ouch: 1)
LaGear::Publisher.new.publish(:test_worker3, ouch: 1)
sleep 3
puts 'killing...'
Process.kill('TERM', pid)
sleep 3
puts "test_worker message count #{queue.message_count}"
puts "test_worker2 message count #{queue2.message_count}"
puts "test_worker3 message count #{queue3.message_count}"
exit 1 if queue.message_count > 0
