# frozen_string_literal: true

module Hausgold
  # A HAUSGOLD ecosystem user account with the bare details of his identity. It
  # does not contain any personal data such as first- or lastnames. These
  # information is decentralized located at each applications scope. Say you
  # want to retrive the personal data of a broker, then you need to ask the
  # Maklerportal API. The user entities share all the same id (UUID), but
  # differ on the gid (Global Id) according to the specific application.
  class User < BaseEntity
    # The low level client
    client :identity_api

    # Mapped and tracked attributes
    tracked_attr :id, :gid, :email, :type, :status, :last_login_at,
                 :created_at, :updated_at, :confirmed_at, :locked_at,
                 :recovery_at, :password, :password_confirmation

    # Confirm the current user instance.
    # No additional options required for this, but you can pass in a +metadata+
    # argument as hash with additional workflow data.
    #
    # @param args [Hash{Symbol => Mixed}] additional options
    # @return [Hausgold::User] the current user instance
    def confirm(**args)
      client.confirm_user(self, args)
    end

    # Revoke the confirmation of the current user instance.
    # No additional options required for this.
    #
    # @param args [Hash{Symbol => Mixed}] additional options
    # @return [Hausgold::User] the current user instance
    def unconfirm(**args)
      client.unconfirm_user(self, args)
    end

    # Start the account recovery for the current user instance.
    # No additional options required for this, but you can pass in a +metadata+
    # argument as hash with additional workflow data.
    #
    # @param args [Hash{Symbol => Mixed}] additional options
    # @return [Hausgold::User] the current user instance
    def recover(**args)
      client.recover_user(self, args)
    end

    # Finish the account recovery for the current user instance.
    # You need to pass in the +token+ and +password+ as additional parameters.
    #
    # @param token [String] the recovery token
    # @param password [String] the new password of the user
    # @param args [Hash{Symbol => Mixed}] additional options
    # @return [Hausgold::User] the current user instance
    def recovered(token:, password:, **args)
      params = { token: token, password: password }.merge(args)
      client.recovered_user(self, **params)
    end

    # Lock the current user instance.
    # No additional options required for this, but you can pass in a +metadata+
    # argument as hash with additional workflow data.
    #
    # @param args [Hash{Symbol => Mixed}] additional options
    # @return [Hausgold::User] the current user instance
    def lock(**args)
      client.lock_user(self, args)
    end

    # Unlock the current user instance.
    # You need to pass in the +token+ and +password+ as additional parameters.
    #
    # @param token [String] the unlock token
    # @param password [String] the current password of the user
    # @param args [Hash{Symbol => Mixed}] additional options
    # @return [Hausgold::User] the current user instance
    def unlock(token:, password:, **args)
      params = { token: token, password: password }.merge(args)
      client.unlock_user(self, **params)
    end

    # Build an user identifier hash from the given user instance. It puts the
    # +id+, or the +email+ as identifier. When both are missing we raise an
    # +ArgumentError+. The +id+ takes precedence over the +email+.
    #
    # @return [Hash{Symbol => Mixed}] the identifier hash
    def identifier
      params = { id: id, email: email }.compact
      params.delete(:email) if params.key? :id
      raise ArgumentError, "#{self} identifier missing (id or email)" \
        if params.empty?

      params
    end

    # Generate bang method variants
    bangers :confirm, :lock, :recover, :recovered, :unconfirm, :unlock
  end
end
