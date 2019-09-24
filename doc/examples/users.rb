#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative './config'

email = "test-user-#{Time.current.to_i}@example.com"
password = SecureRandom.hex(16)

# Create a user account (silently, we set him to inactive and pass a random
# password who nobody knows)
user = Hausgold::User.create(email: email,
                             password: password,
                             password_confirmation: password,
                             type: :customer,
                             status: :inactive)

# Start the activation workflow for the user
user.activate

# Finish the activation workflow for the user
# user = Hausgold::User.find('995ce288-9e8d-4d72-a635-2914b3886d0b')
# user.activated(token: '5889f65657dbc07d8b6daab9d72aba83',
#                password: 'new-password')
