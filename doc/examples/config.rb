# frozen_string_literal: true

require 'bundler/setup'
require 'hausgold'

Hausgold.reset_configuration!
Hausgold.configure do |conf|
  conf.app_name = 'local-example'
  conf.env = :local
  conf.request_logging = false
  conf.identity_scheme = :password
  conf.identity_params = { email: 'identity-api@hausgold.de',
                           password: 'Oacbos8otAc=' }
end
