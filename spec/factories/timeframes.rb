# frozen_string_literal: true

FactoryBot.define do
  factory :timeframe, class: Hausgold::Timeframe do
    start_at { Time.current + 2.days }
    end_at { start_at + 1.hour }
    user_id { SecureRandom.uuid }
    reference_ids { 1.upto(rand(2..5)).map { SecureRandom.uuid } }
    metadata { { add_1: true, add_2: 1.day.from_now, add_3: 'Info' } }
  end

  factory :timeframe_minimum, class: Hausgold::Timeframe do
    start_at { Time.current + 2.days }
    end_at { start_at + 1.hour }
    user_id { SecureRandom.uuid }
  end
end
