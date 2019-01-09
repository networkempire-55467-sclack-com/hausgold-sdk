# frozen_string_literal: true

module Hausgold
  # A collection of URL/domain helpers for the applications on the HAUSGOLD
  # ecosystem.
  module Url
    extend ActiveSupport::Concern

    class_methods do
      # Allow users to retrieve the domain name for a given app on the given
      # environment. When no environment is specified we use the configured
      # one.
      #
      # @param app [String] the app name (eg. +asset-api+)
      # @param env [String, Symbol] the environment to use
      # @return [String] the application domain
      def app_domain(app, env = Hausgold.env)
        case env.to_sym
        when :production
          "#{app}.hausgold.de"
        when :canary
          "#{app}.canary.hausgold.de"
        when :local
          "#{app}.local"
        else
          raise "Environment #{env} unknown"
        end
      end

      # Allow users to retrieve the URL of the given app on the given
      # environment. When no environment is specified we use the configured
      # one.
      #
      # @param app [String] the app name (eg. +asset-api+)
      # @param env [String, Symbol] the environment to use
      # @return [String] the application URL
      def app_url(app, env = Hausgold.env)
        proto = %i[production canary].include?(env.to_sym) ? 'https' : 'http'
        "#{proto}://#{app_domain(app, env)}"
      end
    end
  end
end
