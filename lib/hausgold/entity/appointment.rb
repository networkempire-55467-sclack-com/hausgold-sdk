# frozen_string_literal: true

module Hausgold
  # The HAUSGOLD ecosystem includes abstract appointments for all kind of
  # entities. Users can have appointments, or even properties if you like to.
  class Appointment < BaseEntity
    # The low level client
    client :calendar_api

    # Mapped and tracked attributes
    tracked_attr :id, :gid, :title, :description, :location, :start_at,
                 :end_at, :editable, :status, :user_id, :reference_ids,
                 :attendee_ids, :created_at, :updated_at, :alarms, :metadata
  end
end
