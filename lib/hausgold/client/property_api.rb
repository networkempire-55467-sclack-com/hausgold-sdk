# frozen_string_literal: true

module Hausgold
  module Client
    # A high level client library for the Property API.
    class PropertyApi < Base
      include Hausgold::ClientUtils::GrapeCrud
      include Hausgold::PropertyApi::SearchProfiles

      # Configure the application to use
      app 'property-api'

      # Define all the CRUD resources
      entity :property, '/v1/properties'
      entity :search_profile, '/v1/search_profiles'
    end
  end
end
