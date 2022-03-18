require_relative 'helper'

class TestSneakersConfigurer < LaGear::Test
  describe '#configure_bi_amqp_endpoints' do
    it 'must set Sneakers amqp config' do
      expected_base_uri = 'amqp://username@myrabbitmqhost.net:10000'
      expected_vhost = 'vhost_name'
      full_uri = "#{expected_base_uri}/#{expected_vhost}"
      expected_publish_base_uri = 'amqp://username@myrabbitmqhost.net:10001'
      expected_publish_vhost = 'publish_vhost_name'
      full_publish_uri = "#{expected_publish_base_uri}/#{expected_publish_vhost}"

      LaGear::SneakersConfigurer.configure_bi_amqp_endpoints(full_uri, full_publish_uri)

      Sneakers::CONFIG[:amqp].must_equal expected_base_uri
      Sneakers::CONFIG[:vhost].must_equal expected_vhost
      Sneakers::CONFIG[:amqp_publish].must_equal expected_publish_base_uri
      Sneakers::CONFIG[:vhost_publish].must_equal expected_publish_vhost
    end
  end
end
