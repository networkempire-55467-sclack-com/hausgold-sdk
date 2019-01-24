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

        # Use the default request context to identificate the request.
        #
        # @param req [Faraday::Request] the request to manipulate
        def use_default_context(req)
          req.options.context ||= {}
          req.options.context.merge!(client: app_name,
                                     action: request_action,
                                     request_id: SecureRandom.hex(3))
        end

        private

        # Get the request starting action/method name from the caller backtrace.
        #
        # @return [String] the starting request action/method name
        def request_action
          # Parse the client action from the caller backtrace
          methods = caller.each_with_object([]) do |call, memo|
            next if call.include?('block in')
            next if call.include?('use_default_context')
            next if call.exclude?('hausgold/client')

            memo << call[/`.*'/][1..-2]
          end
          # When only two are available, it sounds like a abstraction, so
          # we use the most specific one
          return methods.last if methods.count == 2

          # Otherwise we use the first method
          methods.first
        end
      end
    end
  end
end
