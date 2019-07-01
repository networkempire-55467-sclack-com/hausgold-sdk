# frozen_string_literal: true

FactoryBot.define do
  factory :property, class: Hausgold::Property do
    owner_id { SecureRandom.uuid }
    object_details do
      { street: FFaker::AddressDE.street,
        city: FFaker::AddressDE.city }
    end
    source { :crm }
    created_at { Time.zone.yesterday }
    updated_at { Time.zone.now }
  end
end
