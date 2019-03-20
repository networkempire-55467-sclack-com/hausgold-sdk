# frozen_string_literal: true

FactoryBot.define do
  factory :pdf, class: Hausgold::Pdf do
    url { 'https://maintenance.hausgold.de' }
    landscape { true }
    background { true }
    media { 'screen' }
  end
end
