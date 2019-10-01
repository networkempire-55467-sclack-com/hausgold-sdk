# frozen_string_literal: true

FactoryBot.define do
  factory :customer, class: Hausgold::Customer do
    email { FFaker::Internet.free_email }
    gender { %w[male female].sample }
    first_name do
      meth = gender[0] == 'm' ? :first_name_male : :first_name_female
      FFaker::NameDE.send(meth)
    end
    last_name { FFaker::NameDE.last_name }
    phone { FFaker::PhoneNumberDE.home_work_phone_number }
    mobile { FFaker::PhoneNumberDE.international_mobile_phone_number }
    address { build(:address) }
    status { :active }
    password { 'password' }
  end
end
