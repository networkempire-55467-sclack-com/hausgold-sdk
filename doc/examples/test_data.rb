#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative './config'

# Create a new testing customer with dependent data in place. We call this
# instrumentation which is handy for automated end-to-end tests.
pp Hausgold.app(:kundenportal_api)
           .instrument_customer!(:with_identity,
                                 :with_address,
                                 :with_property,
                                 property_type: :site)

# Create a new testing broker with an active lead.
pp Hausgold.app(:maklerportal_api)
           .instrument_broker!(:confirmed,
                               :with_avatar,
                               :with_lead,
                               lead_traits: %i[active realty_type])

# Use the defaults while generating a new customer.
pp Hausgold.app(:kundenportal_api).instrument_customer!

# We also provide a generic instrumentation client interface, so you do not
# need to know the actual client/application when you generate a testing
# entity. This becomes very handy in dynamic contexts. This call is equal to
# the previous one.
pp Hausgold.instrument!(:customer)
