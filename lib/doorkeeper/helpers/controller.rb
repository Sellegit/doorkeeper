module Doorkeeper
  module Helpers
    module Controller
      def self.included(base)
        base.send :private,
                  :authenticate_resource_owner!,
                  :authenticate_admin!,
                  :current_resource_owner,
                  :resource_owner_from_credentials,
                  :skip_authorization?
      end

      def authenticate_resource_owner!
        current_resource_owner
      end

      def current_resource_owner
        instance_eval(&Doorkeeper.configuration.authenticate_resource_owner)
      end

      def resource_owner_from_credentials
        instance_eval(&Doorkeeper.configuration.resource_owner_from_credentials)
      end

      def vendor_resource_owner_from_request
        instance_eval &Doorkeeper.configuration.vendor_resource_owner_from_request
      end

      def authenticate_admin!
        instance_eval(&Doorkeeper.configuration.authenticate_admin)
      end

      def server
        @server ||= Server.new(self)
      end

      def get_error_response_from_exception(exception)
        error_name = case exception
        when Errors::InvalidTokenStrategy
          :unsupported_grant_type
        when Errors::InvalidAuthorizationStrategy
          :unsupported_response_type
        when Errors::MissingRequestStrategy
          :invalid_request
        when Errors::CustomError
          exception.error_name
        end

        OAuth::ErrorResponse.new :name => error_name, :state => params[:state]
      end

      def handle_token_exception(exception)
        case exception
        when Errors::TypedError
          self.response_body = exception.params.merge(error_type: exception.error_type).to_json
          self.status = exception.status
        else
          error = get_error_response_from_exception exception
          self.headers.merge!  error.headers
          self.status        = error.status
          self.response_body = error.body.to_json
        end
      end

      def skip_authorization?
        !!instance_exec([@server.current_resource_owner, @pre_auth.client], &Doorkeeper.configuration.skip_authorization)
      end
    end
  end
end
