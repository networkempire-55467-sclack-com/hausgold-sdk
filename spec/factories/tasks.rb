# frozen_string_literal: true

FactoryBot.define do
  factory :task, class: Hausgold::Task do
    title { 'Do something meaningful' }
    description { 'Meaningful description with many details' }
    location { '04179 Leipzig Leutzsch' }
    due_date { 2.days.from_now }
    user_id { SecureRandom.uuid }
    reference_ids { 1.upto(rand(2..5)).map { SecureRandom.uuid } }
    metadata { { add_1: true, add_2: 1.day.from_now, add_3: 'Info' } }

    factory :readonly_task do
      editable { false }
    end
  end

  factory :task_minimum, class: Hausgold::Task do
    title { 'test' }
    user_id { SecureRandom.uuid }
  end
end
