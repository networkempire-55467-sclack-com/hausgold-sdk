# frozen_string_literal: true

module Hausgold
  module AnalyticApi
    # All the query functionalities.
    module Query
      extend ActiveSupport::Concern

      included do
        # Query the data points.
        #
        # @param args [Hash{Symbol => Mixed}] additional request params
        # @return [Hausgold::DataPointsResult] the mapped result set
        #
        # rubocop:disable Metrics/AbcSize, Metrics/MethodLength because
        #   thats the bare minimum
        def query_data_points(**args)
          res = connection.get do |req|
            req.path = '/v1/data_points'
            req.params = args
            use_default_context(req)
            use_jwt(req)
          end
          decision(bang: args.fetch(:bang, false)) do |result|
            result.bang do
              raise_on_errors(res, Hausgold::DataPointsResult, args)
            end
            result.good do
              attrs = res.body.metadata.to_h.merge(data: res.body.data)
              Hausgold::DataPointsResult.new(**attrs)
            end
            successful?(res)
          end
        end
        # rubocop:enable Metrics/AbcSize, Metrics/MethodLength

        # Generate bang method variants
        bangers :query_data_points
      end
    end
  end
end
