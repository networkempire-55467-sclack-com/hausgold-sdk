# frozen_string_literal: true

module Hausgold
  # Rails-specific initializations.
  class Railtie < Rails::Railtie
    # Run before all Rails initializers, but after the application is defined
    config.before_initialize do
      # Reset the default application name (which is +nil+), because the Rails
      # application was not defined when the HAUSGOLD SDK was loaded
      Hausgold.configuration.app_name = Hausgold.local_app_name
    end

    # Run after all configuration is set via Rails initializers
    config.after_initialize do
      # Re-register application GID locators
      Hausgold.register_gid_locators
    end
  end
end
