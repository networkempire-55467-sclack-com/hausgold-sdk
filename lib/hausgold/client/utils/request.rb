# frozen_string_literal: true

module Hausgold
  module ClientUtils
    # Some helpers to prepare requests in a general way.
    module Request
      extend ActiveSupport::Concern

      included do
        # Use the configured identity to authenticate the given request.
        #
        # @param req [Faraday::Request] the request to manipulate
        def use_jwt(req)
          req.headers.merge!('Authorization' => \
                             "Bearer #{Hausgold.identity.access_token}")
        end
      end
    end
  end
end
