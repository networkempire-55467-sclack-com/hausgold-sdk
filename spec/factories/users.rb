# frozen_string_literal: true

FactoryBot.define do
  factory :user, class: Hausgold::User do
    sequence :email do |num|
      "#{FFaker::Internet.user_name}#{num}@#{FFaker::Internet.domain_name}"
    end
    password { FFaker::Internet.password }
    password_confirmation { password }
    type { :employee }
    status { :active }
  end

  factory :user_minimal, class: Hausgold::User do
    sequence :email do |num|
      "#{FFaker::Internet.user_name}#{num}@#{FFaker::Internet.domain_name}"
    end
    password { FFaker::Internet.password }
    password_confirmation { password }
    type { :employee }
  end
end
