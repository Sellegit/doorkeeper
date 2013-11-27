module Doorkeeper::OAuth
  class VendorOauthRequest
    include Doorkeeper::Validations
    include Doorkeeper::OAuth::Helpers

    validate :client,                :error => :invalid_client
    validate :vendor_resource_owner, :error => :invalid_resource_owner
    validate :scopes,                :error => :invalid_scope

    attr_accessor :server, :client, :vendor_resource_owner, :state

    def initialize(server, client, current_server, parameters = {})
      @server                = server
      @client                = client
      @original_scopes       = parameters[:scope]
      @current_server        = current_server
    end

    def authorize
      validate
      @response = if valid?
        find_or_create_access_token
        TokenResponse.new access_token
      else
        ErrorResponse.from_request self
      end
    end

    def valid?
      self.error.nil?
    end

    def access_token
      return unless client.present? && vendor_resource_owner.present?
      @access_token ||= Doorkeeper::AccessToken.matching_token_for client, vendor_resource_owner.id, scopes
    end

    def scopes
      @scopes ||= if @original_scopes.present?
        Doorkeeper::OAuth::Scopes.from_string(@original_scopes)
      else
        server.default_scopes
      end
    end

  private

    def find_or_create_access_token
      if access_token
        access_token.expired? ? revoke_and_create_access_token : access_token
      else
        create_access_token
      end
    end

    def revoke_and_create_access_token
      access_token.revoke
      create_access_token
    end

    def create_access_token
      @access_token = Doorkeeper::AccessToken.create!({
        :application_id     => client.id,
        :resource_owner_id  => vendor_resource_owner.id,
        :scopes             => scopes.to_s,
        :expires_in         => server.access_token_expires_in,
        :use_refresh_token  => false,
      })
    end

    def validate_client
      !!client
    end

    def validate_scopes
      return true unless @original_scopes.present?
      ScopeChecker.valid?(@original_scopes, @server.scopes)
    end

    def validate_vendor_resource_owner
      begin
        !!(@vendor_resource_owner ||= @current_server.vendor_resource_owner)
      rescue Doorkeeper::Errors::InvalidVendorResourceOwnerError => e
        @state = e.error_state 
        @error = :invalid_resource_owner
        false
      end
    end
  end
end
