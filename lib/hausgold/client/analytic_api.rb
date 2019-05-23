# frozen_string_literal: true

module Hausgold
  module Client
    # A high level client library for the Analytic API.
    class AnalyticApi < Base
      # Include all the features
      include Hausgold::ClientUtils::GrapeCrud
      include Hausgold::AnalyticApi::Query

      # Configure the application to use
      app 'analytic-api'

      # Define all the CRUD resources
      entity :data_point, '/v1/data_points', only: %i[create]
      entity :data_point_entity, '/v1/entities', only: %i[find create delete]
    end
  end
end
