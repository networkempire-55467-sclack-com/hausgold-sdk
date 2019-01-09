# frozen_string_literal: true

module Hausgold
  module EntityConcern
    # Allow entities to define their low level HTTP client to use.
    module Client
      extend ActiveSupport::Concern

      included do
        # The class constant of the low level client
        class_attribute :client_class

        # Get the cached low level client instance.
        #
        # @return [Mixed] the client instance
        def client
          @client ||= client_class.new
        end
      end

      class_methods do
        # Allows an entity to configure the client it depends on.
        #
        # @param name [Symbol, String] the client name, in snake_case
        def client(name)
          self.client_class = \
            name.to_s.camelcase.prepend('Hausgold::Client::').constantize
        end
      end
    end
  end
end
