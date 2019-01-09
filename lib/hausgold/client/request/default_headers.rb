# frozen_string_literal: true

module Hausgold
  module Request
    # Add some default headers to every request.
    class DefaultHeaders < Faraday::Middleware
      # Serve the Faraday middleware API.
      #
      # @param env [Hash{Symbol => Mixed}] the request
      def call(env)
        env[:request_headers].merge! \
          'User-Agent' => user_agent,
          'Content-Type' => 'application/json',
          'Accept' => 'application/json'

        @app.call(env)
      end

      # Build an useful user agent string to pass. We identify ourself as
      # +HausgoldSDK+ with the current gem version and a user definable
      # application name. You should set it accordingly to identify yourself.
      # The application name should include the application version as well.
      # (eg. +identity-api/214202e+, with the Git commit short reference)
      #
      # @return [String] the user agent string
      def user_agent
        "HausgoldSDK/#{Hausgold::VERSION}" \
          " #{Hausgold.configuration.app_name}"
      end
    end
  end
end
