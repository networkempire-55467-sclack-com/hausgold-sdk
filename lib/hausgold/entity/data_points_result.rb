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
  end
end
