module LaGear
  class UriParser
    def initialize(uri_str)
      @uri = URI(uri_str)
    end

    def amqp
      "#{@uri.scheme}://#{@uri.userinfo}@#{@uri.host}:#{@uri.port}"
    end

    def vhost
      @uri.path.gsub!(/^\//, '')
    end
  end
end
