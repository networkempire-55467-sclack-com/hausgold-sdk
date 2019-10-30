# frozen_string_literal: true

module Hausgold
  module Client
    # A high level client library for the Maklerportal API.
    class MaklerportalApi < Base
      # Include all the features
      include Hausgold::ClientUtils::GrapeCrud

      # Configure the application to use
      app 'maklerportal-api'

      # Define all the CRUD resources
      entity :user, '/v2/users', class_name: Hausgold::Broker
    end
  end
end
