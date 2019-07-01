# frozen_string_literal: true

module Hausgold
  module Client
    # A high level client library for the Property API.
    class PropertyApi < Base
      include Hausgold::ClientUtils::GrapeCrud

      # Configure the application to use
      app 'property-api'

      # The property entity available in the Property API.
      entity :property, '/v1/properties'
    end
  end
end
