# frozen_string_literal: true

module Hausgold
  # A bunch of top-level client helpers.
  module Client
    extend ActiveSupport::Concern

    class_methods do
      # Get a low level client for the requested application. This returns an
      # already instantiated client object, ready to use.
      #
      # @param name [Symbol, String] the application name
      # @return [Hausgold::Client::Base] a compatible client instance
      def app(name)
        resolve_app(name)
          .to_s
          .underscore
          .camelize
          .prepend('Hausgold::Client::')
          .constantize
          .new
      end

      # Resolve an application name. When the application name is an configured
      # alias we return the alias destination. The input allows all kind of
      # naming conventions like camelcase, pascalcase, kebabcase, snakecase
      # (strings and symbols). The result is always a symbol in kebabcase.
      #
      # @param name [Symbol, String] the application name
      # @return [Symbol] the kebabcase'd variant of the given application name
      def resolve_app(name)
        # Sanitize the given name to allow various inputs
        mapped = name.to_s.underscore.dasherize.to_sym
        # Search for the given name on the aliases list
        result = Configuration::API_ALIASES.find do |alisases, _|
          alisases.include? mapped
        end
        # Return the resolved name if we found a resolution
        return result.last if result.present?

        # Otherwise use return the given name
        mapped
      end
    end
  end
end
