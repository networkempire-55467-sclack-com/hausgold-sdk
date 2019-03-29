# frozen_string_literal: true

module Hausgold
  # The HAUSGOLD ecosystem allows rich data point queries with aggregations,
  # time gap fillups and adjustable data resolution. This entity is just a data
  # model for the result set of a successful query.
  class DataPointsResult < BaseEntity
    # Mapped and tracked attributes
    tracked_attr :entity, :metric, :context, :aggregation, :interval,
                 :start_at, :end_at, :total_count, :total_value, :data

    # Define attribute types for casting
    typed_attr :metric, :symbol
    typed_attr :context, :symbol
    typed_attr :aggregation, :symbol
    typed_attr :interval, :symbol
    typed_attr :data, :recursive_open_struct_array

    # Check that the data points result set was build by actual data points.
    # The result set may also contain just out of gap-filling data points. This
    # can be detected by their respective individual count. When the count for
    # a single data point is zero, its a gap-filler. We check all resulting
    # data points, and look at least for one containing a positive count.
    #
    # @return [Boolean] whenever real data was present, or not
    def data_points_available?
      data.select { |point| point.count.positive? }.any?
    end
  end
end
