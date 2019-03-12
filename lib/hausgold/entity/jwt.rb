# frozen_string_literal: true

module Hausgold
  # A regular (J)son (W)eb (T)oken which acts as an authentication and
  # authorization key to the HAUSGOLD ecosystem. It is passed as header to each
  # request you do on an HAUSGOLD service.
  class Jwt < BaseEntity
    # The expiration leeway to substract to guarantee
    # acceptance on remote application calls
    EXPIRATION_LEEWAY = 5.minutes

    # The low level client
    client :identity_api

    # Mapped and tracked attributes
    tracked_attr :token_type, :access_token, :bare_access_token,
                 :refresh_token, :expires_in

    # Define attribute types for casting
    typed_attr :token_type, :string_inquirer

    # Add some runtime attributes
    attr_reader :created_at

    # Associations
    has_one :user

    # Register the time of initializing as base for the expiration
    after_initialize { @created_at = Time.current }

    # Allow to query whenever the current JWT instance is expired or not. This
    # includes also a small leeway to ensure the acceptance is guaranteed.
    #
    # @return [Boolean] whenever the JWT instance is expired or not
    def expired?
      # When no expiration time is specified, eg. for partial access
      expires_at = created_at + (expires_in || 1.year.to_i) - EXPIRATION_LEEWAY
      Time.current >= expires_at
    end
  end
end
