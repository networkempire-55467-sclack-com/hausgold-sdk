# frozen_string_literal: true

module Hausgold
  # The configuration for the HAUSGOLD SDK.
  class Configuration
    include ActiveSupport::Configurable

    # API services, you can access with a client
    API_NAMES = %i[asset-api calendar-api identity-api jabber pdf-api
                   preferences property-api verkaeuferportal-api
                   maklerportal-api analytic-api].freeze

    # Used to identity this client on the user agent header
    config_accessor(:app_name) { Hausgold.local_app_name }

    # HAUSGOLD environment to use
    config_accessor(:env) { :canary }

    # Allow to set the SDK identity credentials
    config_accessor(:identity_renewal) { true }
    config_accessor(:identity_scheme) { :password }
    config_accessor(:identity_params) { { email: '', password: '' } }

    # General logging facility
    config_accessor(:logger) { Logger.new($stdout) }
    # Enable request logging or not
    config_accessor(:request_logging) { true }

    # Enable/Disable local-GID locator support - enabling it may cause issue on
    # locating local models because of same named applications. Say you include
    # the HAUSGOLD SDK in a application named +AssetApi+, then local-GIDs will
    # look like +gid://asset-api/..+. The +Hausgold::Client+ namespace also has
    # a +AssetApi+ client which is registered (or not) as GID locator client.
    # By using the +app_name+ we strip off the local application from the GID
    # locators.
    config_accessor(:exclude_local_app_gid_locator) { true }
  end
end
