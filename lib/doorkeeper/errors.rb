module Doorkeeper
  module Errors
    class DoorkeeperError < StandardError
    end

    class InvalidAuthorizationStrategy < DoorkeeperError
    end

    class InvalidTokenStrategy < DoorkeeperError
    end

    class MissingRequestStrategy < DoorkeeperError
    end

    class TypedError < DoorkeeperError
      attr_accessor :error_type, :params, :status
      def initialize(error_type, params={})
        super(params[:message] || (error_type.to_s + ": " + params.inspect))
        @error_type = error_type
        @params = params
        @status = params[:status] || 400
      end
    end

    class CustomError < DoorkeeperError
      attr_accessor :error_name
      def initialize(msg, error_name)
        super(msg)
        @error_name = error_name
      end
    end

    class InvalidVendorResourceOwnerError < DoorkeeperError
      attr_accessor :error_state
      def initialize(msg, error_state=nil)
        super(msg)
        @error_state = error_state
      end
    end

  end
end
