require 'json'

class JsBinClient
  class Rest
    def initialize(options)
      @options = options
    end

    def get(path)
      rest_request :get, "#{end_point}#{path}", headers
    end

    def put(path, params = {})
      rest_request :put, "#{end_point}#{path}", params, headers
    end

    def post(path, params = {})
      rest_request :post, "#{end_point}#{path}", params, headers
    end

    private
      def end_point
        "#{@options.ssl ? 'https' : 'http'}://#{@options.host}:#{@options.port}/#{API_PREFIX}"
      end

      def headers
        if @options.respond_to?(:api_key)
          { authorization: "token #{@options.api_key}" }
        else
          {}
        end
      end

      def rest_request(*args)
        begin
          IndifferentJson.new(RestClient.send(args.first, *args[1..-1]))
        rescue JSON::ParserError => e
          raise InvalidJson, e.message
        rescue RestClient::ResourceNotFound => e
          raise BinMissing, e.message
        rescue RestClient::RequestFailed => e
          if e.message =~ /^403/
            message = JSON.parse(e.response)['error'] rescue nil
            exception = if !message.nil? && message.match(/owner/)
              OwnershipError
            else
              AuthenticationRequired
            end
            raise exception, message || e.message
          else
            raise e
          end
        end
      end

      class IndifferentJson
        def initialize(json_string)
          @json = JSON.parse(json_string)
        end

        def [](id)
          @json[id.to_s]
        end

        def keys
          @json.keys
        end

        def values
          @json.values
        end
      end
  end
end