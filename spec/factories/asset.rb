# frozen_string_literal: true

FactoryBot.define do
  factory :asset, class: Hausgold::Asset do
    transient do
      owner_app { 'identify-api' }
      owner_entity { 'User' }
      owner_id { SecureRandom.uuid }
    end

    title { 'My avatar' }
    description { 'The best avatar I ever had' }
    attachable { "gid://#{owner_app}/#{owner_entity}/#{owner_id}" }
    permissions { { owner_id => 'x' } }
    metadata { { add_1: true, add_2: 1.day.from_now, add_3: 'Info' } }
    file { UploadIO.new(file_fixture('avatar.jpg'), 'image/jpeg') }
    add_attribute(:public) { true }

    trait :private do
      add_attribute(:public) { false }
    end

    trait :with_file_url do
      file_url { "http://asset-api.local/v1/assets/#{id}/download" }
    end

    trait :with_file_from_url do
      file { nil }
      file_from_url do
        'https://s3-eu-west-1.amazonaws.com/asset-api-test/avatar.jpg'
      end
    end
  end
end
