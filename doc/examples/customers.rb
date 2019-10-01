#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative './config'

# Create a brand new customer on the Verkaeuferportal/Kundenportal API
user = Hausgold::Customer.create!(
  email: "test-customer-#{Time.current.to_i}@example.com",
  first_name: 'Peter',
  last_name: 'Mustermann',
  gender: :male,
  mobile: '+49-160-5556-421',
  phone: '+49-152-5558-916',
  address: {
    street: 'Weisenheimer Weg 141',
    city: 'Erpolzheim',
    zipcode: '67167',
    country_code: 'de'
  },
  status: :active,
  # When the status is set to +:inactive+ you can skip passing the +password+
  # attribute because it wont be processed
  password: 'secret-password'
)

# Watchout for the resulting Global Id
pp user.gid
# => "gid://verkaeuferportal-api/User/..."

# Hausgold.locate('gid://verkaeuferportal-api/User/...')
user = Hausgold.locate(user.gid)
# => <Hausgold::Customer ...>

# **Heads up!** Partial nested hash updates will result in data loss due to the
# fact that the APIs do not support HTTP PATCH. The +#update+ calls will
# perform a HTTP PUT in low level, so nested data is overwritten.
user.update(address: { city: 'Berlin' }).address
# => {:street=>nil, :street_addition=>nil, :city=>"Berlin", ...}

# Send a +property_created+ notification for the user.
#
# @deprecated This will be removed in future SDK releases in favor of a direct
#   message bus event consumption on the Verkaeuferportal API.
user.property_created_notification!(property_id: SecureRandom.uuid)
