# frozen_string_literal: true

FactoryBot.define do
  factory :property, class: Hausgold::Property do
    owner_id { SecureRandom.uuid }
    sequence(:lead_id) { |n| "00000#{n}AB1234" }
    object_details do
      { street: FFaker::AddressDE.street,
        city: FFaker::AddressDE.city }
    end
    source { :crm }
    metadata do
      { foo: 'bar', something_done_at: Time.zone.now.iso8601 }
    end
    created_at { Time.zone.yesterday }
    updated_at { Time.zone.now }
  end
end
