#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative './config'

# Create a brand new customer on the Maklerportal API (this is only allowed by
# machine users, because we do not offer a public registration)
user = Hausgold::Broker.create!(
  email: "test-broker-#{Time.current.to_i}@example.com",
  first_name: 'Max',
  last_name: 'Mustermann',
  gender: :male,
  contact_phone: '+49-152-5558-916',
  password: 'secret-password'
)

# Watchout for the resulting Global Id
pp user.gid
# => "gid://maklerportal-api/User/..."

# Hausgold.locate('gid://maklerportal-api/User/...')
pp user = Hausgold.locate(user.gid)
# => <Hausgold::Broker ...>

# You can query the gender easily with the inquirer
pp user.gender.male?
# => true

# Updates works as usual, so lets update our lastname
user.update!(last_name: 'Müller')

# Search for brokers by some criteria (eg. name) - this is
# also limited to machine users
pp Hausgold::Broker.where(text: 'Müller').count
# => 1
