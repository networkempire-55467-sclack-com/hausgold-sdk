# frozen_string_literal: true

module Hausgold
  module ClientUtils
    # A generic client concern to generate test data on demand with the help of
    # the +factory_bot+/+factory_bot_instrumentation+ gem.
    #
    # @see https://github.com/hausgold/factory_bot_instrumentation
    module FactoryBotInstrumentation
      extend ActiveSupport::Concern

      included do |base|
        # Keep track of all instrumentation entities of a client class, we have
        # to set the default via the +base+ reader here to be Rails 4
        # compatible
        class_attribute :factories_i13n
        base.factories_i13n = {}

        # Perform a create request on the given path, with the given attributes.
        # This results in a "create a single entity" request.
        #
        # @param attributes [Hash{String => Mixed}] the attributes to send
        # @return [Faraday::Response] the response
        def create_i13n(attributes = {})
          connection.post do |req|
            req.path = '/instrumentation'
            req.body = attributes.deep_compact
            use_format(req, :json)
            use_default_context(req)
          end
        end
      end

      class_methods do
        # Configure a new nstrumentation factory action.
        #
        # @param name [String, Symbol] the singular entity name
        # @param args [Hash{Symbol => Mixed}] additional options
        def factory_i13n(name, **args)
          # Fetch the desired remote factory name, we use the +name+
          # argument as fall back
          factory = args.fetch(:factory, name).to_sym
          args = args.merge(factory: factory)
          # Fetch the desired entity class just once for
          # all the definition calls to keep it DRY
          class_name = entity_class_name(name, **args)
          args = args.merge(class_name: class_name)
          # Track the factory name and its configuration
          self.factories_i13n = factories_i13n.merge(name => args)
          # Define an instrumentation action for the given factory
          define_factory_i13n_create(name, factory, class_name)
        end

        private

        # Define an instrumentation action for the given factory.
        #
        # @param name [String, Symbol] the singular entity name
        # @param factory [String, Symbol] the remote factory name
        # @param class_name [Class] the class of the entity
        def define_factory_i13n_create(name, factory, class_name)
          class_eval <<-RUBY, __FILE__, __LINE__ + 1
            # Create a new entity via instrumentation.
            #
            # @param bang [Boolean] whenever to raise exceptions or not
            # @param traits [Array<String, Symbol>] the factory traits to use
            # @param overwrite [Hash{Symbol => Mixed}] overwrite properties
            # @return [#{class_name}, nil] the entity, or +nil+ on error
            def instrument_#{name}(*traits, bang: false, **overwrite)
              attrs = { factory: :#{factory}, traits: traits,
                        overwrite: overwrite }
              res = create_i13n(attrs)
              decision(bang: bang) do |result|
                result.bang(&bang_entity(#{class_name}, res, **attrs))
                result.good { #{class_name}.new(res.body).clear_changes }
                successful?(res)
              end
            end

            # Generate bang method variants
            bangers :instrument_#{name}
          RUBY
        end
      end
    end
  end
end
