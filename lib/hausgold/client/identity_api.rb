# frozen_string_literal: true

module Hausgold
  module Client
    # A high level client library for the Identity API.
    class IdentityApi < Base
      # Include all the features
      include Hausgold::ClientUtils::GrapeCrud
      include Hausgold::IdentityApi::Authentication
      include Hausgold::IdentityApi::Users

      # Configure the application to use
      app 'identity-api'

      # Define all the CRUD resources
      entity :user, '/v1/users'
    end
  end
end
