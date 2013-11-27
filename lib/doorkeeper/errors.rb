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

    class InvalidVendorResourceOwnerError < DoorkeeperError
      attr_accessor :error_state
      def initialize(msg, error_state=nil)
        super(msg)
        @error_state = error_state
      end
    end

  end
end
