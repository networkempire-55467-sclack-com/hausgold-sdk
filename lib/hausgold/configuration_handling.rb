# frozen_string_literal: true

module Hausgold
  # The top-level configuration handling.
  #
  # rubocop:disable Style/ClassVars because we split module code
  module ConfigurationHandling
    extend ActiveSupport::Concern

    class_methods do
      # Retrieve the current configuration object.
      #
      # @return [Configuration]
      def configuration
        @@configuration ||= Configuration.new
      end

      # Configure the concern by providing a block which takes
      # care of this task. Example:
      #
      #   FactoryBot::Instrumentation.configure do |conf|
      #     # conf.xyz = [..]
      #   end
      def configure
        yield(configuration)
      end

      # Reset the current configuration with the default one.
      def reset_configuration!
        @@configuration = Configuration.new
      end

      # Retrieve the current configured environment. You can use it like
      # +Rails.env+ to query it. E.g. +Hausgold.env.production?+.
      #
      # @return [ActiveSupport::StringInquirer] the environment
      def env
        @@env = ActiveSupport::StringInquirer.new(configuration.env.to_s) \
          if @env.to_s != configuration.env.to_s
        @@env
      end
    end
  end
  # rubocop:enable Style/ClassVars
end
