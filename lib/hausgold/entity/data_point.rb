# frozen_string_literal: true

module Hausgold
  # The HAUSGOLD ecosystem allows the tracking of metrics in an abstract way.
  # The underlying Analytic API acts as a time series database with rich query
  # functionalities. A single data point represents a point in time (in an
  # entity/context/metric hierarchie).
  class DataPoint < BaseEntity
    # The low level client
    client :analytic_api

    # Mapped and tracked attributes
    tracked_attr :context, :metric, :entity, :value,
                 :captured_at, :created_at, :updated_at

    class << self
      # Query the data points.
      def query(entity:, context:, metric:, **args)
        required = { entity: entity, context: context, metric: metric }
        client_class.new.query_data_points(**args.merge(required))
      end

      # Generate bang method variants
      bangers :query
    end
  end
end
