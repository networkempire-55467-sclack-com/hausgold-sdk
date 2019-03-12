# frozen_string_literal: true

module Hausgold
  module Client
    # A high level client library for the Asset API.
    class AssetApi < Base
      # Include all the features
      include Hausgold::ClientUtils::GrapeCrud
      include Hausgold::AssetApi::Downloads

      # Configure the application to use
      app 'asset-api'

      # Define all the CRUD resources
      entity :asset, '/v1/assets', formats: { create: :multipart }
    end
  end
end
