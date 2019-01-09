# frozen_string_literal: true

module Hausgold
  # Handles all the identity retrival high-level logic, including masquerading.
  #
  # rubocop:disable Style/ClassVars because we split module code
  module Identity
    extend ActiveSupport::Concern

    # rubocop:disable Metrics/BlockLength because its a ActiveSupport::Concern
    class_methods do
      # Reset the current identity.
      def reset_identity!
        @@identity = nil
      end

      # Get/set the current identity we use for all requests. We allow the user
      # to send in attributes (symbol hashed) to build a new +Hausgold::Jwt+
      # instance on demand. This is helpful in cases you only have an access
      # token, without anything else. We also allow to pass in a prebuilt
      # +Hausgold::Jwt+ instance and just set it. Both is also true for a given
      # block, as an argument source. The block takes precedence over the
      # passed in arguments.
      #
      # When none arguments are passed, we act as a getter. In case the
      # identity was not set previously, we try to authenticate against the
      # Identity API with the configured credentials from the Gem
      # configuration. (+Hausgold.configuration+) In case this went well, we
      # cache the result. Otherwise we raise an +AuthenticationError+.
      #
      # @param args [Array<Mixed>] the new identity data
      # @yield and use the result as new identity data
      # @return [Hausgold::Jwt] the JWT instance in charge
      # @raise [AuthenticationError] in case of a failed login
      def identity(*args)
        # Collect arguments from a block when given
        args = yield if block_given?
        # Unwrap the arguments, because the source may vary
        args = [args].flatten
        if args.first
          args = args.first
          # Create an JWT instance on demand, or use the given one
          jwt = args.is_a?(Hausgold::Jwt) ? args : Hausgold::Jwt.new(**args)
          # Set the JWT instance
          return @@identity = jwt
        end
        # Pass back the JWT instance, or fetch a new one with the
        # configured identity settings from the Gem configuration
        @@identity ||= auth_by_config
      end

      # Switch the current identity/JWT instance for the runtime of the given
      # block. After the given block was evaluated, we switch back to the
      # previous identity.
      #
      # @param jwt [Hausgold::Jwt] the identity to use
      # @yield the given block
      # @yieldparam [Hausgold::Jwt] the new identity
      # @yieldparam [Hausgold::Jwt] the old identity
      # @return [Mixed] the outcome of the block
      def switch_identity(jwt)
        original = identity
        identity(jwt)
        result = yield(jwt, original)
        identity(original)
        result
      end

      # Perform the given block in the name of a different identity. You can
      # pass an actual +Hausgold::Jwt+ instance to use, or you can pass the
      # desired user as +Hausgold::User+ instance. Furthermore we accept the
      # id/gid/email (user UUID/user Global Id) of the user as criteria. For
      # possible batch/low level processing we support an access token from a
      # JWT bundle as a string.
      #
      # @param criteria [Hausgold::Jwt, Hausgold::User, String] the user
      #   criteria
      # @yield the given block with enabled masquerading
      # @yieldparam [Hausgold::Jwt] the new JWT identity
      # @return [Mixed] the outcome of the block
      def as_user(criteria, &block)
        # Collect masquerading parameters, when available
        masquerade = masquerade_params(criteria)
        # Detect direct identity criterias, so we dont need to fetch them
        jwt = criteria if criteria.is_a? Hausgold::Jwt
        jwt = Hausgold::Jwt.new(**criteria) if criteria.is_a? Hash
        jwt = Hausgold::Jwt.new(access_token: criteria) if masquerade.empty?
        # Fetch a new JWT with the masquerading parameters, via the configured
        # identity credentials
        jwt ||= auth_by_config(masquerade: masquerade)
        # Perform the given block and pass the new identity to it
        switch_identity(jwt, &block)
      end

      private

      # Perform the authentication via the configured identity credentials. You
      # can pass additional data to replace the configured credentials, or add
      # masquerading parameters.
      #
      # @param additional [Hash{Symbol => Mixed }] additional authentication
      #   parameters
      # @return [Hausgold::Jwt] the new JWT instance
      # @raise [AuthenticationError] in case of a failed login
      def auth_by_config(**additional)
        args = configuration.identity_params.dup.merge(additional)
        app(:identity_api).login!(scheme: configuration.identity_scheme, **args)
      end

      # Collect masquerading data (uuid or email of the user we want to
      # masquerade) from all sort of data.  You can pass in a normal
      # application identifier (UUID), a Global Id, an email address, or a
      # +Hausgold::User+ instance.  The result is a hash which can be passed to
      # an authentication request beneath the +masquerade+ namespace. In case
      # no masquerading parameters are found, we pass back an empty hash, for
      # compatiblity.
      #
      # @param criteria [Hausgold::User, String] the user identifier
      # @return [Hash{Symbol => String }] the masquerading parameters
      def masquerade_params(criteria)
        match = Hausgold::Utils::Matchers
        result = {}
        result = { id: match.uuid(criteria) } if criteria.is_a? String
        result = { email: criteria } if match.email? criteria
        result = { id: criteria.id } if criteria.is_a? Hausgold::User
        result.compact
      end
    end
    # rubocop:enable Metrics/BlockLength
  end
  # rubocop:enable Style/ClassVars
end
