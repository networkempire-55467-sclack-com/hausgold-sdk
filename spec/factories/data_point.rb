# frozen_string_literal: true

# rubocop:disable RSpec/MissingExampleGroupArgument, RSpec/EmptyExampleGroup
#   because +context+ is not RSpec related here
FactoryBot.define do
  factory :data_point, class: Hausgold::DataPoint do
    transient do
      entity_app { 'identify-api' }
      entity_model { 'User' }
      entity_id { SecureRandom.uuid }
    end

    captured_at { 1.hour.ago }
    entity { "gid://#{entity_app}/#{entity_model}/#{entity_id}" }
    context { 'user' }

    metric { 'login' }
    value { rand(0..1000).to_d }
    permissions do
      { entity_id => 'r' }
    end
  end
end
# rubocop:enable RSpec/MissingExampleGroupArgument, RSpec/EmptyExampleGroup
