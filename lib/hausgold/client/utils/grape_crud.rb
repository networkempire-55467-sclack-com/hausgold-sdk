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
        # @param format [Symbol] the request format to use
        # @return [Faraday::Response] the response
        def find(path, id, format = :json)
          return not_found unless (id = enforce_uuid(id))

          connection.get do |req|
            req.path = "#{path}/#{id}"
            use_format(req, format)
            use_default_context(req)
            use_jwt(req)
          end
        end

        # Perform a search request on the given path, with the given filters.
        # This results in a "get multiple entities" request.
        #
        # @param path [String] the path to use for the URL
        # @param filters [Hash{Symbol => Mixed}] the search filters
        # @param format [Symbol] the request format to use
        # @return [Faraday::Response] the response
        def search(path, filters = {}, format = :json)
          connection.get do |req|
            req.path = path.to_s
            req.params = filters
            use_format(req, format)
            use_default_context(req)
            use_jwt(req)
          end
        end

        # Perform a create request on the given path, with the given attributes.
        # This results in a "create a single entity" request.
        #
        # @param path [String] the path to use for the URL
        # @param attributes [Hash{String => Mixed}] the attributes to send
        # @param format [Symbol] the request format to use
        # @return [Faraday::Response] the response
        def create(path, attributes = {}, format = :json)
          connection.post do |req|
            req.path = path.to_s
            req.body = attributes.deep_compact
            use_format(req, format)
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
        # @param format [Symbol] the request format to use
        # @return [Faraday::Response] the response
        def update(path, id, attributes = {}, format = :json)
          return not_found unless (id = enforce_uuid(id))

          connection.put do |req|
            req.path = "#{path}/#{id}"
            req.body = attributes
            use_format(req, format)
            use_default_context(req)
            use_jwt(req)
          end
        end

        # Perform a delete request on the given path, with the given identifier.
        # This results in a "delete a single entity" request.
        #
        # @param path [String] the path to use for the URL
        # @param id [String] the entity identifier
        # @param format [Symbol] the request format to use
        # @return [Faraday::Response] the response
        def delete(path, id, format = :json)
          return not_found unless (id = enforce_uuid(id))

          connection.delete do |req|
            req.path = "#{path}/#{id}"
            use_format(req, format)
            use_default_context(req)
            use_jwt(req)
          end
        end

        # Convert a criteria object to respective Grape API pagination
        # parameters which can be passed the low level +#search+ method.
        #
        # @param criteria [Hausgold::SearchCriteria] the search criteria
        # @return [Hash{Symbol => Mixed}] the search parameters
        def criteria_to_filters(criteria)
          criteria.where.merge(page: criteria.current_page,
                               per_page: criteria.per_page)
        end
      end

      class_methods do
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
            # @return [#{class_name}, nil] the entity, or +nil+ on error
            def find_#{name}(id, **args)
              res = find('#{path}', id, format(:#{name}, :find))
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

        # Define a simple find method for the given entity.
        #
        # @param name [String, Symbol] the singular entity name
        # @param path [String] the API path of the entity
        # @param class_name [Class] the class of the entity
        def define_entity_search(name, path, class_name)
          class_eval <<-RUBY, __FILE__, __LINE__ + 1
            # Fetch multiple entities by criteria.
            #
            # @param criteria [Hausgold::SearchCriteria] the search criteria
            # @param args [Hash{Symbol => Mixed}] additional options
            # @return [#{class_name}, nil] the entity, or +nil+ on error
            def search_#{name.to_s.pluralize}(criteria, **args)
              filters = criteria_to_filters(criteria)
              res = search('#{path}', filters, format(:#{name}, :search))

              # By convention the elements are stored under the entity name
              # (snake_case, pluralized)
              elements_key = #{class_name}.remote_entity_name
                                          .underscore.pluralize
              elements = res.body.send(elements_key)

              decision(bang: args.fetch(:bang, false)) do |result|
                result.bang(&bang_entities(criteria, res))
                result.good(&assign_entities(#{class_name}, elements))
                successful?(res)
              end
            end

            # Generate bang method variants
            bangers :search_#{name.to_s.pluralize}
          RUBY
        end

        # Define a simple reload via find method for the given entity.
        #
        # @param name [String, Symbol] the singular entity name
        # @param path [String] the API path of the entity
        # @param class_name [Class] the class of the entity
        def define_entity_reload(name, path, class_name)
          class_eval <<-RUBY, __FILE__, __LINE__ + 1
            # Reload a single entity.
            #
            # @param entity [Hausgold::BaseEntity] the entity to reload
            # @param args [Hash{Symbol => Mixed}] additional options
            # @return [#{class_name}, nil] the entity, or +nil+ on error
            def reload_#{name}(entity, **args)
              res = find('#{path}', entity.id, format(:#{name}, :find))
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
        # @param class_name [Class] the class of the entity
        def define_entity_create(name, path, class_name)
          class_eval <<-RUBY, __FILE__, __LINE__ + 1
            # Create a single entity.
            #
            # @param entity [Hausgold::BaseEntity] the entity to create
            # @param args [Hash{Symbol => Mixed}] additional options
            # @return [#{class_name}, nil] the entity, or +nil+ on error
            def create_#{name}(entity, **args)
              res = create('#{path}', entity.attributes,
                           format(:#{name}, :create))
              decision(bang: args.fetch(:bang, false)) do |result|
                result.bang(&bang_entity(entity, res, id: entity.try(:id)))
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
        # @param class_name [Class] the class of the entity
        def define_entity_update(name, path, class_name)
          class_eval <<-RUBY, __FILE__, __LINE__ + 1
            # Update a single entity.
            #
            # @param entity [Hausgold::BaseEntity] the entity to update
            # @param args [Hash{Symbol => Mixed}] additional options
            # @return [#{class_name}, nil] the entity, or +nil+ on error
            def update_#{name}(entity, **args)
              changes = entity.attributes.slice(*entity.changed)
              return entity if changes.empty?
              res = update('#{path}', entity.id, changes,
                           format(:#{name}, :update))
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
        # @param class_name [Class] the class of the entity
        def define_entity_delete(name, path, class_name)
          class_eval <<-RUBY, __FILE__, __LINE__ + 1
            # Delete a single entity.
            #
            # @param entity [Hausgold::BaseEntity] the entity to delete
            # @param args [Hash{Symbol => Mixed}] additional options
            # @return [#{class_name}, nil] the entity, or +nil+ on error
            def delete_#{name}(entity, **args)
              res = delete('#{path}', entity.id, format(:#{name}, :delete))
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
