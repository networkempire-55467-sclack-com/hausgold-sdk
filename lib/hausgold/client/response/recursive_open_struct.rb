# frozen_string_literal: true

module Hausgold
  module Response
    # Convert every response body to an +RecursiveOpenStruct+ for an easy
    # access.
    class RecursiveOpenStruct < Faraday::Middleware
      # Serve the Faraday middleware API.
      #
      # @param env [Hash{Symbol => Mixed}] the request
      def call(env)
        @app.call(env).on_complete do |res|
          body = {}

          body = res[:body] unless res[:status] == 204 || res[:body].empty?

          res[:body] = \
            ::RecursiveOpenStruct.new(body, recurse_over_arrays: true)
        end
      end
    end
  end
end
