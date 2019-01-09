# frozen_string_literal: true

module Hausgold
  # A bunch of top-level client helpers.
  module Client
    extend ActiveSupport::Concern

    class_methods do
      # Get a low level client for the requested application. This returns an
      # already instanciated client object, ready to use.
      #
      # @param name [Symbol, String] the application name
      # @return [Hausgold::Client::Base] a compatible client instance
      def app(name)
        name.to_s
            .tr('-', '_')
            .camelcase
            .prepend('Hausgold::Client::')
            .constantize
            .new
      end
    end
  end
end
