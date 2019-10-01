# frozen_string_literal: true

FactoryBot.define do
  factory :address, class: Hausgold::Address do
    street { FFaker::AddressDE.street_address }
    street_addition { FFaker::AddressDE.secondary_address }
    city { FFaker::AddressDE.city }
    country_code { %w[de at ch].sample }
    zipcode { FFaker::AddressDE.zip_code }
  end
end
