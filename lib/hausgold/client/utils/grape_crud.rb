# frozen_string_literal: true

module Hausgold
  module ClientUtils
    # The common CRUD operations for a regular Grape API application.
    #
    # rubocop:disable Metrics/ModuleLength because of ActiveSupport::Concern
    # rubocop:disable Metrics/BlockLength because of ActiveSupport::Concern
    module GrapeCrud
      extend ActiveSupport::Concern

      included do
        # Perform a find request on the given path, with the given identifier.
        # This results in a "get a single entity" request.
        #
        # @param path [String] the path to use for the URL
        # @param id [String] the identifier (eg. UUID/Gid)
        # @return [Faraday::Response] the response
        def find(path, id)
          id = Hausgold::Utils::Matchers.uuid(id)
          return not_found unless Hausgold::Utils::Matchers.uuid? id

          connection.get do |req|
            req.path = "#{path}/#{id}"
            use_default_context(req)
            use_jwt(req)
          end
        end

        # Perform a create request on the given path, with the given attributes.
        # This results in a "create a single entity" request.
        #
        # @param path [String] the path to use for the URL
        # @param attributes [Hash{String => Mixed}] the attributes to send
        # @return [Faraday::Response] the response
        def create(path, attributes = {})
          connection.post do |req|
            req.path = path.to_s
            req.body = attributes.compact
            use_default_context(req)
            use_jwt(req)
          end
        end

        # Perform an update request on the given path, with the given
        # attributes. This results in a "update single entity" request.
        #
        # @param path [String] the path to use for the URL
        # @param id [String] the entity identifier
        # @param attributes [Hash{String => Mixed}] the attributes to send
        # @return [Faraday::Response] the response
        def update(path, id, attributes = {})
          id = Hausgold::Utils::Matchers.uuid(id)
          return not_found unless Hausgold::Utils::Matchers.uuid? id

          connection.put do |req|
            req.path = "#{path}/#{id}"
            req.body = attributes
            use_default_context(req)
            use_jwt(req)
          end
        end

        # Perform a delete request on the given path, with the given identifier.
        # This results in a "delete a single entity" request.
        #
        # @param path [String] the path to use for the URL
        # @param id [String] the entity identifier
        # @return [Faraday::Response] the response
        def delete(path, id)
          id = Hausgold::Utils::Matchers.uuid(id)
          return not_found unless Hausgold::Utils::Matchers.uuid? id

          connection.delete do |req|
            req.path = "#{path}/#{id}"
            use_default_context(req)
            use_jwt(req)
          end
        end
      end

      class_methods do
        # Allows a client to generate CRUD methods for a regular Grape API.
        #
        # @param name [String, Symbol] the singular entity name
        # @param path [String] the API path of the entity
        # @param args [Hash{Symbol => Mixed}] additional options
        def entity(name, path, **args)
          class_name = args.fetch(:class_name, nil)
          class_name ||= name.to_s.camelcase.prepend('Hausgold::').constantize
          # Define all the CRUD methods on the class
          define_entity_find(name, path, class_name)
          define_entity_reload(name, path)
          define_entity_create(name, path)
          define_entity_update(name, path)
          define_entity_delete(name, path)
        end

        private

        # Define a simple find method for the given entity.
        #
        # @param name [String, Symbol] the singular entity name
        # @param path [String] the API path of the entity
        # @param class_name [Class] the class of the entity
        def define_entity_find(name, path, class_name)
          class_eval <<-RUBY, __FILE__, __LINE__ + 1
            # Fetch a single entity by its identifier (UUID/Gid).
            #
            # @param id [String] the identifier
            # @param args [Hash{Symbol => Mixed}] additional options
            # @return [#{class_name}, nil] the task entity, or +nil+ on error
            def find_#{name}(id, **args)
              res = find('#{path}', id)
              decision(bang: args.fetch(:bang, false)) do |result|
                result.bang(&bang_entity(#{class_name}, res, id: id))
                result.good { #{class_name}.new(res.body).clear_changes }
                successful?(res)
              end
            end

            # Generate bang method variants
            bangers :find_#{name}
          RUBY
        end

        # Define a simple reload via find method for the given entity.
        #
        # @param name [String, Symbol] the singular entity name
        # @param path [String] the API path of the entity
        def define_entity_reload(name, path)
          class_eval <<-RUBY, __FILE__, __LINE__ + 1
            # Reload a single entity.
            #
            # @param entity [Hausgold::BaseEntity] the entity to reload
            # @param args [Hash{Symbol => Mixed}] additional options
            # @return [Hausgold::BaseEntity, nil] the entity, or +nil+ on error
            def reload_#{name}(entity, **args)
              res = find('#{path}', entity.id)
              decision(bang: args.fetch(:bang, false)) do |result|
                result.bang(&bang_entity(entity, res, id: entity.id))
                result.good(&assign_entity(entity, res))
                successful?(res)
              end
            end

            # Generate bang method variants
            bangers :reload_#{name}
          RUBY
        end

        # Define a simple create method for the given entity.
        #
        # @param name [String, Symbol] the singular entity name
        # @param path [String] the API path of the entity
        def define_entity_create(name, path)
          class_eval <<-RUBY, __FILE__, __LINE__ + 1
            # Create a single entity.
            #
            # @param entity [Hausgold::BaseEntity] the entity to create
            # @param args [Hash{Symbol => Mixed}] additional options
            # @return [Hausgold::BaseEntity, nil] the entity, or +nil+ on error
            def create_#{name}(entity, **args)
              res = create('#{path}', entity.attributes)
              decision(bang: args.fetch(:bang, false)) do |result|
                result.bang(&bang_entity(entity, res, id: entity.id))
                result.good(&assign_entity(entity, res) do |entity|
                  entity.send(:clear_changes_information)
                end)
                successful?(res)
              end
            end

            # Generate bang method variants
            bangers :create_#{name}
          RUBY
        end

        # Define a simple update method for the given entity.
        #
        # @param name [String, Symbol] the singular entity name
        # @param path [String] the API path of the entity
        def define_entity_update(name, path)
          class_eval <<-RUBY, __FILE__, __LINE__ + 1
            # Update a single entity.
            #
            # @param entity [Hausgold::BaseEntity] the entity to update
            # @param args [Hash{Symbol => Mixed}] additional options
            # @return [Hausgold::BaseEntity, nil] the entity, or +nil+ on error
            def update_#{name}(entity, **args)
              changes = entity.attributes.slice(*entity.changed)
              return entity if changes.empty?
              res = update('#{path}', entity.id, changes)
              decision(bang: args.fetch(:bang, false)) do |result|
                result.bang(&bang_entity(entity, res, id: entity.id))
                result.good(&assign_entity(entity, res))
                successful?(res)
              end
            end

            # Generate bang method variants
            bangers :update_#{name}
          RUBY
        end

        # Define a simple delete method for the given entity.
        #
        # @param name [String, Symbol] the singular entity name
        # @param path [String] the API path of the entity
        def define_entity_delete(name, path)
          class_eval <<-RUBY, __FILE__, __LINE__ + 1
            # Delete a single entity.
            #
            # @param entity [Hausgold::BaseEntity] the entity to delete
            # @param args [Hash{Symbol => Mixed}] additional options
            # @return [Hausgold::BaseEntity, nil] the entity, or +nil+ on error
            def delete_#{name}(entity, **args)
              res = delete('#{path}', entity.id)
              decision(bang: args.fetch(:bang, false)) do |result|
                result.bang(&bang_entity(entity, res, id: entity.id))
                result.good(&assign_entity(entity, res) do |entity|
                  entity.mark_as_destroyed.freeze
                end)
                successful?(res)
              end
            end

            # Generate bang method variants
            bangers :delete_#{name}
          RUBY
        end
      end
    end
    # rubocop:enable Metrics/BlockLength
    # rubocop:enable Metrics/ModuleLength
  end
end
