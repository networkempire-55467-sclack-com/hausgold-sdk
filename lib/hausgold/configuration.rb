# frozen_string_literal: true

module Hausgold
  # The configuration for the HAUSGOLD SDK.
  class Configuration
    include ActiveSupport::Configurable

    # API services, you can access with a client
    API_NAMES = %i[asset-api calendar-api identity-api jabber pdf-api
                   preferences property-api verkaeuferportal-api
                   maklerportal-api].freeze

    # Used to identity this client on the user agent header
    config_accessor(:app_name) { nil }

    # HAUSGOLD environment to use
    config_accessor(:env) { :canary }

    # Allow to set the SDK identity credentials
    config_accessor(:identity_scheme) { :password }
    config_accessor(:identity_params) { { email: '', password: '' } }
  end
end
