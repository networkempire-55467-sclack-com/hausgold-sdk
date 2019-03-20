# frozen_string_literal: true

FactoryBot.define do
  factory :data_point_entity, class: Hausgold::DataPointEntity do
    transient do
      entity_app { 'identify-api' }
      entity_model { 'User' }
      entity_id { SecureRandom.uuid }
    end

    gid { "gid://#{entity_app}/#{entity_model}/#{entity_id}" }
    permissions do
      { entity_id => 'r' }
    end
  end
end
