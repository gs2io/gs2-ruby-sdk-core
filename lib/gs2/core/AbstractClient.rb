require 'gs2-sdk'
require 'openssl'
require 'base64'
require 'httpclient'
require 'json'

require 'gs2/core/BadRequestException.rb'
require 'gs2/core/BadGatewayException.rb'
require 'gs2/core/InternalServerErrorException.rb'
require 'gs2/core/NotFoundException.rb'
require 'gs2/core/QuotaExceedException.rb'
require 'gs2/core/RequestTimeoutException.rb'
require 'gs2/core/ServiceUnavailableException.rb'
require 'gs2/core/UnauthorizedException.rb'
require 'gs2/core/ConflictException.rb'

module Gs2 module Core
  class AbstractClient
    
    @@ENDPOINT_BASE = 'https://{service}.{region}.gs2.io'
    
    def initialize(region, gs2_client_id, gs2_client_secret)
      @region = region
      @gs2_client_id = gs2_client_id
      @gs2_client_secret = gs2_client_secret
    end
    
    def create_sign(_module, function, timestamp)
      message = _module + ':' + function + ':' + timestamp.to_s
      return Base64.strict_encode64(OpenSSL::HMAC::digest(OpenSSL::Digest::SHA256.new, Base64.strict_decode64(@gs2_client_secret), message))
    end

    def get(_module, function, endpoint, url, query = {}, extheader = {})
      url = (@@ENDPOINT_BASE + url).gsub(/{service}/, endpoint).gsub(/{region}/, @region)
      client = HTTPClient.new
      timestamp = Time.now.to_i
      header = {
        'X-GS2-CLIENT-ID' => @gs2_client_id,
        'X-GS2-REQUEST-TIMESTAMP' => timestamp,
        'X-GS2-REQUEST-SIGN' => create_sign(_module,function,timestamp),
        'Content-Type' => 'application/json'
      }
      header.merge!(extheader)
      return handling(client.get(url, query: query, header: header))
    end

    def post(_module, function, endpoint, url, body, query = {}, extheader = {})
      url = (@@ENDPOINT_BASE + url).gsub(/{service}/, endpoint).gsub(/{region}/, @region)
      client = HTTPClient.new
      timestamp = Time.now.to_i
      header = {
        'X-GS2-CLIENT-ID' => @gs2_client_id,
        'X-GS2-REQUEST-TIMESTAMP' => timestamp,
        'X-GS2-REQUEST-SIGN' => create_sign(_module,function,timestamp),
        'Content-Type' => 'application/json'
      }
      header.merge!(extheader)
      return handling(client.post(url, query: query, header: header, body: body.to_json))
    end

    def put(_module, function, endpoint, url, body, query = {}, extheader = {})
      url = (@@ENDPOINT_BASE + url).gsub(/{service}/, endpoint).gsub(/{region}/, @region)
      client = HTTPClient.new
      timestamp = Time.now.to_i
      header = {
        'X-GS2-CLIENT-ID' => @gs2_client_id,
        'X-GS2-REQUEST-TIMESTAMP' => timestamp,
        'X-GS2-REQUEST-SIGN' => create_sign(_module,function,timestamp),
        'Content-Type' => 'application/json'
      }
      header.merge!(extheader)
      return handling(client.put(url, query: query, header: header, body: body.to_json))
    end

    def delete(_module, function, endpoint, url, query = {}, extheader = {})
      url = (@@ENDPOINT_BASE + url).gsub(/{service}/, endpoint).gsub(/{region}/, @region)
      client = HTTPClient.new
      timestamp = Time.now.to_i
      header = {
        'X-GS2-CLIENT-ID' => @gs2_client_id,
        'X-GS2-REQUEST-TIMESTAMP' => timestamp,
        'X-GS2-REQUEST-SIGN' => create_sign(_module,function,timestamp),
        'Content-Type' => 'application/json'
      }
      header.merge!(extheader)
      return handling(client.delete(url, query: query, header: header))
    end
    
    def handling(response)
      case response.status
        when 200
          begin
            return JSON.parse(response.body)
          rescue JSON::ParserError
            return nil
          end
        when 400; raise Gs2::Core::BadRequestException.new(JSON.parse(JSON.parse(response.body)['message']))
        when 401; raise Gs2::Core::UnauthorizedException.new(JSON.parse(JSON.parse(response.body)['message']))
        when 402; raise Gs2::Core::QuotaExceedException.new(JSON.parse(JSON.parse(response.body)['message']))
        when 404; raise Gs2::Core::NotFoundException.new(JSON.parse(JSON.parse(response.body)['message']))
        when 409; raise Gs2::Core::ConflictException.new(JSON.parse(JSON.parse(response.body)['message']))
        when 500; raise Gs2::Core::InternalServerErrorException.new(JSON.parse(JSON.parse(response.body)['message']))
        when 502; raise Gs2::Core::BadGatewayException.new(JSON.parse(JSON.parse(response.body)['message']))
        when 503; raise Gs2::Core::ServiceUnavailableException.new(JSON.parse(JSON.parse(response.body)['message']))
        when 504; raise Gs2::Core::RequestTimeoutException.new(JSON.parse(JSON.parse(response.body)['message']))
      end
      puts response.status
      puts response.body
    end
  end
end end
