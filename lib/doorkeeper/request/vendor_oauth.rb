module Doorkeeper
  module Request
    class VendorOauth
      def self.build(server)
        new(server.client, server)
      end

      attr_accessor :client, :server

      def initialize(client, server)
        @client, @server = client, server
      end

      def request
        @request ||= OAuth::VendorOauthRequest.new(Doorkeeper.configuration, client, server, server.parameters)
      end

      def authorize
        request.authorize
      end
    end
  end
end
