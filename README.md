# L.A. Gear

This gem has two primary purposes:
* Allowing you to define one worker class that has your [`sneakers`](https://github.com/jondot/sneakers) worker queue configuration and the [`sidekiq`](https://github.com/mperham/sidekiq) `perform` method that actually processes the message.
* DRYing up your `sneakers` configuration by using a conventions.

Here are some other features:
* Messages are deserialized as JSON by default and the properties are passed to Sidekiq's `perform_async` method
* Out-of-the-box configuration of `sneakers` for multiple RabbitMQ subscribers
* An alternative to the `Sneakers::Publisher#publish` method that allows you to pass in more options when publishing to a RabbitMQ exchange
* Helper methods for configuring `sneakers`
* Support for configuring `sneakers` with [BigWig](http://bigwig.io/)

DISCLAIMER: This repo contains the source code from the [la_gear](https://rubygems.org/gems/la_gear) gem owned by [giftcardzen](https://rubygems.org/profiles/giftcardzen). This was an account I created while a software engineer at Giftcard Zen. Giftcard Zen was [acquired by RetailMeNot in 2015](https://www.crunchbase.com/acquisition/whale-shark-media-acquires-giftcard-zen--18806c45). RetailMeNot took ownership of the account and the open source projects under the [giftcardzen](https://github.com/giftcardzen) GitHub organization, including the la_gear repo. Unfortunately, RetailMeNot deleted the organization including all open source repos without transferring ownership to contributors.

I finally got around to pulling the source from the gem and pushing it here, mostly for posterity. This represents a piece of my career growth in architecting distributed systems communicating via publish/subscribe.

## Installation

Add this line to your application's Gemfile:

    gem 'la_gear'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install la_gear

## Usage

Instead of `include Sneakers::Worker` in your workers, use `include LaGear::Worker`. Then all of your queues and routing key bindings will automatically use an `Sneakers::Config[:app_name]` plus the class name of your worker as your queue name and the class name of your worker as the routing key. For example,
```ruby
Sneakers.configure app_name: 'pogs_are_awesome'

class BoKnows
  include LaGear::Worker

  def perform(baseball, football)
    # process message ...
  end
end
```
would by default result in the following 2 queue names:

- `pogs_are_awesome.bo_knows`
- `pogs_are_awesome.bo_knows.retry`

The default routing key would be: `bo_knows`. This allows for multiple consumer queue bindings for a direct exchange (see the Multiple Bindings section of https://www.rabbitmq.com/tutorials/tutorial-four-ruby.html). The `.retry` is for if you are using [dead letter exchanges](https://www.rabbitmq.com/dlx.html) and [message expirations](https://www.rabbitmq.com/ttl.html) to perform retries (which you should). Just call the `subscribes_to` method to override the convention-based defaults like so:

```ruby
class PowerRanger
  include LaGear::Worker

  subscribes_to 'bo_knows'

  def perform(red, yellow)
    # process message...
  end
end
```

Or subscribe to multiple routing keys:

```ruby
subscribes_to ['bo_knows', 'pump_it_up']
```

Also, notice in the example above that we don't define a `work` method for `Sneakers::Worker`. That's because `LaGear::Worker` defines it for you. All the method does is deserialize your RabbitMQ message (defaults to JSON) and pass each of the properties as a parameters to Sidekiq's `perform_async` method to process the message. Put your message processing code in a `perform` method instead. That's the method that Sidekiq invokes when it actually processes the message that `LaGear::Worker#work` sent to it.

You can also use the conventions to create versioned workers to more easily handle backwards compatibility when message parameters change. This module/class:

```ruby
module BoKnows
  class V1
    def perform
      # process message...
    end
  end
end
```

would create the routing key `bo_knows.v1` and these queue names:

- `pogs_are_awesome.bo_knows.v1`
- `pogs_are_awesome.bo_knows.v1.retry`

One caveat with `subscribes_to` and versioned workers is that the routing key must be manually incremented when a handler's version increments. If a worker `subscribes_to 'bo_knows.v1'`, and the `bo_knows.v1` message type increments to `bo_knows.v2`, you should create a new version of the worker that subscribes to `bo_knows.v2`.

### The Bus

There is also a `LaGear::Bus` class which is an alternative to the `Sneakers::Publisher`. It adds an `opts` parameter to the `publish` method, allowing you to pass the options you would pass to the `bunny` exchange publish [method](http://reference.rubybunny.info/Bunny/Exchange.html#publish-instance_method) (see http://reference.rubybunny.info/Bunny/Exchange.html#publish-instance_method for the list of options). It also allows you use a common way to publish messages:

- `LaGear::Bus.publish('bo_knows', baseball: 'royals', football: 'cowboys')`
- `LaGear::Bus.publish('bo_knows', { baseball: 'royals', football: 'cowboys' }, version: 2)` - will publish to the exchange with the `bo_knows.v2` routing key
- `LaGear::Bus.publish_in(1.day, 'bo_knows', baseball: 'royals', football: 'cowboys')`
- `LaGear::Bus.publish_at(1.day.from_now, 'bo_knows', baseball: 'royals', football: 'cowboys')`
- `LaGear::Bus.publish_local('bo_knows_local', baseball: 'royals', football: 'cowboys')` - this is for local only (`include Sidekiq::Worker`) workers
- `LaGear::Bus.publish_local_in('bo_knows', { baseball: 'royals', football: 'cowboys' }, 1.day)`

## Contributing

1. Fork it ( https://github.com/[my-github-username]/la_gear/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
