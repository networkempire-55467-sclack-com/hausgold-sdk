# frozen_string_literal: true

module Hausgold
  # The HAUSGOLD ecosystem has an abstract task entity which represents a thing
  # which needs to be done. Everybody can have tasks - users, properties, or
  # anything else. The tasks come with a state which defines them as open,
  # resolved or rejected. They bundle titles and descriptions and can also have
  # alarms (reminders) for optional due dates.
  class Task < BaseEntity
    # The low level client
    client :calendar_api

    # Mapped and tracked attributes
    tracked_attr :id, :gid, :title, :description, :location, :due_date,
                 :editable, :status, :result, :type, :user_id, :reference_ids,
                 :created_at, :updated_at, :metadata, :alarms
  end
end
