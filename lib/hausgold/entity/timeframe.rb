# frozen_string_literal: true

module Hausgold
  # The HAUSGOLD ecosystem allows users to define timeframes. This can be
  # helpful to abstract ranges in time for any kind of reason. A common use
  # case could be an calendar application which should track the possible free
  # time windows of a user.
  class Timeframe < BaseEntity
    # The low level client
    client :calendar_api

    # Mapped and tracked attributes
    tracked_attr :id, :gid, :start_at, :end_at, :user_id, :reference_ids,
                 :created_at, :updated_at, :metadata
  end
end
