# frozen_string_literal: true

module Hausgold
  module ClientUtils
    # A lot of (D)omain (S)pecific (L)anguage helpers to simplify the client
    # classes.
    #
    # rubocop:disable Metrics/BlockLength because of the ActiveSupport concern
    module Dsl
      extend ActiveSupport::Concern

      class_methods do
        # Allows a client to generate CRUD methods for a regular Grape API.
        #
        # @param name [String, Symbol] the singular entity name
        # @param path [String] the API path of the entity
        # @param args [Hash{Symbol => Mixed}] additional options
        def entity(name, path, **args)
          update_action_formats(name, **args)
          define_entity_actions(name, path, **args)
        end

        private

        # Define all configured actions for the given entity. We just register
        # all available actions or just the passed ones (+only+ parameter).
        #
        # @param name [String, Symbol] the singular entity name
        # @param path [String] the API path of the entity
        # @param only [Array<Symbol>] the actions to register
        # @param args [Hash{Symbol => Mixed}] additional options
        def define_entity_actions(name, path,
                                  only: Hausgold::Client::Base::ACTIONS, **args)
          # Fetch the desired entity class just once for
          # all the definition calls to keep it DRY
          class_name = entity_class_name(name, **args)
          # Convert the action name to the API-compliant method,
          # check if it's available and call it
          only
            .map { |method| "define_entity_#{method}".to_sym }
            .select { |method| respond_to?(method, true) }
            .each { |method| send(method, name, path, class_name) }
          # Track the entity configurations
          track_entity(name, path, only, args.merge(class_name: class_name))
        end

        # Get back the guessed class name or the explicitly set one.
        #
        # @param name [String, Symbol, nil] the guessed name
        # @param class_name [Class, nil] the explicit class name
        # @param args [Hash{Symbol => Mixed}] additional options
        # @return [Class] the entity class
        def entity_class_name(name, class_name: nil, **_args)
          class_name || name.to_s.camelcase.prepend('Hausgold::').constantize
        end

        # Assemble the request/response formats configuration, and save it.
        #
        # @param name [String, Symbol, nil] the guessed name
        # @param formats [Hash{Symbol => Symbol}] the action to request
        #   format spec
        # @param args [Hash{Symbol => Mixed}] additional options
        # @return [Hash{Symbol => Hash{Symbol => Symbol}] the entity, to action
        #   request formats spec
        def update_action_formats(name, formats: {}, **_args)
          self.action_formats = action_formats.merge \
            name.to_sym => default_formats.merge(formats)
        end

        # Track a new entity configuration of the client.
        #
        # @param name [String, Symbol] the singular entity name
        # @param path [String] the API path of the entity
        # @param actions [Array<Symbol>] the actions the entity supports
        # @param args [Hash{Symbol => Mixed}] additional options
        def track_entity(name, path, actions, args)
          self.entities = entities.merge(name => {
            path: path,
            actions: actions
          }.merge(args.except(:formats)))
        end
      end
    end
    # rubocop:enable Metrics/BlockLength
  end
end
