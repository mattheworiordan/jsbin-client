class JsBinClient
  class Config
    @host       = 'jsbin.com'
    @ssl        = false
    @basic_port = 80
    @ssl_port   = 443

    class << self
      attr_reader :host, :ssl, :basic_port

      def port
        if ssl
          @ssl_port
        else
          @basic_port
        end
      end

      def to_hash
        {
          host: host,
          ssl:  ssl,
          port: port
        }
      end
    end
  end
end