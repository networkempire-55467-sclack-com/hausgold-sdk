# frozen_string_literal: true

module Hausgold
  module IdentityApi
    # All the authentication relevant actions.
    module Authentication
      extend ActiveSupport::Concern

      included do
        # Perform a login request while sending the passed credentials. We
        # dynamically support all authentication schemes of the Identity API.
        # Here come some examples:
        #
        #   # Password scheme
        #   IdentityApi.login(scheme: :password,
        #                     email: 'test@example.com', password: 'secret')
        #   IdentityApi.login(scheme: :password,
        #                     id: 'your-uuid', password: 'secret')
        #
        #   # Refresh token scheme
        #   IdentityApi.login(scheme: :refresh, refresh_token: 'your-token')
        #
        #   # Legacy MPA scheme
        #   IdentityApi.login(scheme: :mpa,
        #                     access_token: 'your-mpa-access-token')
        #
        # @param scheme [Symbol, String] the authentication scheme to use
        # @param args [Hash{Symbol => Mixed}] the authentication credentials
        # @return [Hausgold::Jwt, nil] the JWT entity, or +nil+ on error
        def login(scheme: :password, **args)
          res = connection.post do |req|
            req.path = "/v1/jwt/#{scheme}"
            req.body = args
          end
          decision(bang: args.fetch(:bang, false)) do |result|
            result.bang \
              { Hausgold::AuthenticationError.new(nil, res) }
            result.good { Hausgold::Jwt.new(res.body).clear_changes }
            successful?(res)
          end
        end

        # Logout/blacklist a given JWT. This allows an user to make his current
        # JWT unusable on the HAUSGOLD ecosystem. Here come some examples:
        #
        #   # Blacklist/logout a JWT by its refresh token
        #   IdentityApi.logout(refresh_token: 'your-token')
        #
        #   # Blacklist/logout a JWT by its fingerpring
        #   IdentityApi.logout(fingerpring: 'your-token-fingerprint')
        #
        # @param args [Hash{Symbol => Mixed}] the options
        # @return [Boolean] whenever the logout was successful
        def logout(**args)
          res = connection.delete do |req|
            req.path = '/v1/jwt'
            req.body = args
          end
          decision(bang: args.fetch(:bang, false)) do |result|
            result.bang { Hausgold::RequestError.new(nil, res) }
            result.fail { false }
            result.good { true }
            successful?(res, code: 204)
          end
        end

        # Generate bang method variants
        bangers :login, :logout
      end
    end
  end
end
