# frozen_string_literal: true

module Hausgold
  # The HAUSGOLD ecosystem features data point entities for the permission
  # handling per time line. This is simple ACL system which may be changed in
  # mid-term future. But for now with the help of the data point entity one can
  # reconfigure the permissions of a time series on demand.
  class DataPointEntity < BaseEntity
    # The low level client
    client :analytic_api

    # Mapped and tracked attributes
    tracked_attr :id, :gid, :permissions, :created_at, :updated_at
  end
end
