# frozen_string_literal: true

module Hausgold
  # The HAUSGOLD ecosystem allows the tracking of abstract notification tokens.
  # These tokens are user to device mappings on the external GCP FireBase
  # service. So we allow a single user to have multiple devices per
  # application. (eg. a desktop brower notification and a iOS native app push
  # message for the Maklerportal)
  class NotificationToken < BaseEntity
    # The low level client
    client :identity_api

    # Mapped and tracked attributes
    tracked_attr :id, :gid, :token, :app_id, :user_id, :project_id
  end
end
