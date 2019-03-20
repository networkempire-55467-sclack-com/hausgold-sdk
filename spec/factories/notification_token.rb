# frozen_string_literal: true

FactoryBot.define do
  factory :notification_token, class: Hausgold::NotificationToken do
    token { SecureRandom.hex(76) }
    app_id { '1:462307856009:ios:e84a2d6303b90403' }
    user_id { SecureRandom.uuid }
    project_id { %w[hausgold-canary hausgold-connect].sample }
  end
end
