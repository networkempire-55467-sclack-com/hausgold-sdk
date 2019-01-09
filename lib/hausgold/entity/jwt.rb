# frozen_string_literal: true

module Hausgold
  # A regular (J)son (W)eb (T)oken which acts as an authentication and
  # authorization key to the HAUSGOLD ecosystem. It is passed as header to each
  # request you do on an HAUSGOLD service.
  class Jwt < BaseEntity
    # The low level client
    client :identity_api

    # Mapped and tracked attributes
    tracked_attr :token_type, :access_token, :refresh_token, :expires_in

    # Associations
    has_one :user
  end
end
