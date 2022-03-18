$: << File.expand_path('../lib', File.dirname(__FILE__))

require 'sneakers'
require 'sneakers/runner'
require_relative 'exponential_backoff'
require 'logger'

::Sneakers.configure(handler: LaGear::Sneakers::Handlers::ExponentialBackoff, workers: 1, threads: 1, prefetch: 1)
::Sneakers.logger.level = Logger::INFO

class ExponentialBackoffWorker
  include ::Sneakers::Worker
  from_queue 'sneakers',
             ack: true,
             threads: 1,
             prefetch: 1,
             timeout_job_after: 60,
             exchange: "sneakers",
             heartbeat: 5,
             arguments: {
               :"x-dead-letter-exchange" => "sneakers-retry"
             }

  def work(msg)
    puts "Got message #{msg} and rejecting now"

    return reject!
  end
end

messages = 1
puts "Feeding messages in"

messages.times { ExponentialBackoffWorker.enqueue("{}") }

puts "Done"

r = ::Sneakers::Runner.new([ExponentialBackoffWorker])
r.run
