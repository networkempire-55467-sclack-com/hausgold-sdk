# frozen_string_literal: true

module Hausgold
  # The HAUSGOLD Property is the central information blob for a physical
  # real estate object.
  class Property < BaseEntity
    # The low level client
    client :property_api

    # Mapped and tracked attributes
    tracked_attr :id, :owner_id, :permissions, :object_details, :lead_id,
                 :metadata, :source, :created_at, :updated_at, :geo_details
  end
end
