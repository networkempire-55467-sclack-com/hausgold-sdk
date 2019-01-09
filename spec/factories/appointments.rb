# frozen_string_literal: true

FactoryBot.define do
  factory :appointment, class: Hausgold::Appointment do
    title { 'Visit the customer' }
    description { 'Make photos, talk to him, earn some money' }
    location { '04179 Leipzig Leutzsch' }
    status { 'accepted' }
    editable { true }
    start_at { Time.current + 2.days }
    end_at { start_at + 1.hour }
    user_id { SecureRandom.uuid }
    reference_ids { 1.upto(rand(2..5)).map { SecureRandom.uuid } }
    attendee_ids { 1.upto(rand(2..5)).map { SecureRandom.uuid } }
    metadata { { add_1: true, add_2: 1.day.from_now, add_3: 'Info' } }

    factory :readonly_appointment do
      editable { false }
    end

    trait :alarms do
      alarms do
        [{ channel: 'email', before_minutes: 15 },
         { channel: 'email', before_minutes: 120 }]
      end
    end
  end

  factory :appointment_minimum, class: Hausgold::Appointment do
    title { 'test' }
    start_at { Time.current + 2.days }
    end_at { start_at + 1.hour }
    user_id { SecureRandom.uuid }
  end
end
