# frozen_string_literal: true

module Hausgold
  module ClientUtils
    # Some helpers to prepare requests in a general way.
    #
    # rubocop:disable Metrics/BlockLength because of ActiveSupport::Concern
    module Request
      extend ActiveSupport::Concern

      included do
        # A common HTTP content type to symbol
        # mapping for correct header settings.
        CONTENT_TYPE = {
          json: 'application/json',
          multipart: 'multipart/form-data',
          url_encoded: 'application/x-www-form-urlencoded'
        }.freeze

        # Use the configured identity to authenticate the given request.
        #
        # @param req [Faraday::Request] the request to manipulate
        def use_jwt(req)
          req.headers.merge!('Authorization' => \
                             "Bearer #{Hausgold.identity.access_token}")
        end

        # Use the configured identity to authenticate the given request on
        # cookie-authentication based applications.
        #
        # @param req [Faraday::Request] the request to manipulate
        def use_jwt_cookie(req)
          cookie = HTTP::Cookie.new('bare_access_token',
                                    Hausgold.identity.bare_access_token)
          req.headers.merge!('Cookie' => cookie.to_s)
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

        # Set the request encoding format which should be used for the given
        # request. The Faraday connection middleware will pick this up.
        #
        # @param req [Faraday::Request] the request to manipulate
        # @param format [Symbol] the request format symbol according
        #   to the +CONTENT_TYPE+ constant mapping
        def use_format(req, format)
          req.headers.merge!('Content-Type' => CONTENT_TYPE[format])
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
    # rubocop:enable Metrics/BlockLength
  end
end
