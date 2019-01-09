# frozen_string_literal: true

# Set the gem configuration according to the test suite.
def reset_test_configuration!
  Hausgold.reset_configuration!
  Hausgold.configure do |conf|
    conf.app_name = 'test-client'
    conf.env = :local
    conf.identity_scheme = :password
    conf.identity_params = { email: 'identity-api@hausgold.de',
                             password: 'Oacbos8otAc=' }
  end
end
