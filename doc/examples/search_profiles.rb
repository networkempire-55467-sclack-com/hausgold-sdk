#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative './config'

# Build the owner id of the search profile
owner_id = Hausgold::Customer.to_gid(SecureRandom.uuid)

# Build a new search profile
profile = Hausgold::SearchProfile.new(user_id: owner_id.to_s,
                                      city: 'Hamburg',
                                      zipcode: '22769',
                                      property_types: %i[house site apartment],
                                      # The perimeter (radius in meters) in
                                      # combination with the city/zipcode
                                      perimeter: 50_000,
                                      price_from: 80_000,
                                      price_to: Float::INFINITY)

# Persist the new search profile
profile.save!

# Search all search profiles of the owner
pp Hausgold::SearchProfile.where(user_id: owner_id.to_s).to_a
# => [#<Hausgold::SearchProfile ...>]

# Fetch all matching properties for the search profile
pp profile.properties.to_a
# => [#<Hausgold::Property ..]

# You can also tweak the sorting, by default the newest created properties are
# first. See the API documentation for all supported sorting keys.
pp profile.properties.sort(year_of_construction: :desc).count
# => 1
