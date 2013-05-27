module Doorkeeper
  module Request
    class VendorOauth
      def self.build(server)
        new(server.client, server.vendor_resource_owner, server)
      end

      attr_accessor :client, :vendor_resource_owner, :server

      def initialize(client, vendor_resource_owner, server)
        @client, @vendor_resource_owner, @server = client, vendor_resource_owner, server
      end

      def request
        @request ||= OAuth::VendorOauthRequest.new(Doorkeeper.configuration, client, vendor_resource_owner, server.parameters)
      end

      def authorize
        request.authorize
      end
    end
  end
end
