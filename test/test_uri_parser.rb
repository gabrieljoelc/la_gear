require_relative 'helper'

class TestUriParser < LaGear::Test
  describe '#amqp' do
    before do
      @expected_base_uri = 'amqp://username@myrabbitmqhost.net:10001'
      @expected_vhost = 'vhost_name'
      @full_uri = "#{@expected_base_uri}/#{@expected_vhost}"
    end

    it 'must parse the URI leaving only the protocol, username, host and port' do
      LaGear::UriParser.new(@full_uri).amqp.must_equal @expected_base_uri
    end

    it 'must parse the URI leaving only the vhost' do
      LaGear::UriParser.new(@full_uri).amqp.must_equal @expected_base_uri
    end
  end
end
