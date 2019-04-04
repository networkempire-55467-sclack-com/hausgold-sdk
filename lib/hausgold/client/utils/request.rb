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

        # For some requests we must ensure the given identifier is a valid
        # UUID. This method also applies some force to cast UUIDs from GIDs,
        # too. It also can be configured to ignore/untouch non-UUIDs by the
        # +force_uuid_ids+ class attribute.
        #
        # @param id [String] the identifier to use
        # @return [String, Boolean] the (un)touched id, or +false+ for
        #   broken UUIDs
        def enforce_uuid(id)
          # When we must not enforce UUIDs, we keep it untouched
          return id unless force_uuid_ids?

          # Force the given id into a UUID, if possible
          id = Hausgold::Utils::Matchers.uuid(id)
          # Pass back the enforced UUID, when valid - otherwise +false+
          Hausgold::Utils::Matchers.uuid?(id) ? id : false
        end

        private

        # Get the request starting action/method name from the caller backtrace.
        #
        # @return [String] the starting request action/method name
        #
        # rubocop:disable Metrics/AbcSize because of the reverse engineering
        # rubocop:disable Metrics/CyclomaticComplexity because of the
        #   reverse engineering
        def request_action
          # Parse the client action from the caller backtrace
          methods = caller.each_with_object([]) do |call, memo|
            next if call.include?('block in')
            next if call.include?('use_default_context')
            next if call.exclude?('hausgold/client')

            memo << call[/`.*'/][1..-2]
          end

          # We use the most specific method (2nd) when we are in a locate call
          return methods.second \
            if methods.last == 'locate' && methods.count == 3

          # When only two are available, it sounds like an abstraction, so
          # we use the most specific one
          return methods.last if methods.count == 2

          # Otherwise we use the first method
          methods.first
        end
        # rubocop:enable Metrics/AbcSize
        # rubocop:enable Metrics/CyclomaticComplexity
      end
    end
    # rubocop:enable Metrics/BlockLength
  end
end
