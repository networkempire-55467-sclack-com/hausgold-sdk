# frozen_string_literal: true

module Hausgold
  module EntityConcern
    # Map almost all of the ActiveRecord::Persistence API methods for an entity
    # instance for good compatibility. See: http://bit.ly/2W1rjfF and
    # http://bit.ly/2ARRFYB
    #
    # rubocop:disable Metrics/ModuleLength because of the ActiveSupport::Concern
    module Persistence
      extend ActiveSupport::Concern

      included do
        # A simple method to query for the state of the entity instance.
        # Returns +false+ whenever the entity or the changes of it were not yet
        # persisted on the remote application. This is helpful for creating new
        # entities from scratch or checking for persisted updates.
        #
        # @return [Boolean] whenever persisted or not
        def persisted?
          return (new_record? ? false : !changed?) \
            if respond_to? :id

          false
        end

        # A simple method to query for the state of the entity instance.
        # Returns +false+ whenever the entity is not yet created on the remote
        # application. This is helpful for creating new entities from scratch.
        #
        # @return [Boolean] whenever persisted or not
        def new_record?
          return id.nil? if respond_to? :id

          true
        end

        # Mark the entity instance as destroyed.
        #
        # @return [Hausgold::BaseEntity] the instance itself for method chaining
        def mark_as_destroyed
          @destroyed = true
          self
        end

        # Returns true if this object has been destroyed, otherwise returns
        # false.
        #
        # @return [Boolean] whenever the entity was destroyed or not
        def destroyed?
          @destroyed == true
        end

        # Reloads the entity from the remote application.
        # This method finds the entity by its identifier (which could be
        # assigned manually) and modifies the receiver in-place:
        #
        #   user = Hausgold::User.new
        #   # => #<Hausgold::User id: nil, email: nil>
        #   user.id = 'uuid'
        #   user.reload
        #   # => #<Hausgold::User id: 'uuid', email: 'account@example.com'>
        #
        # @return [Hausgold::BaseEntity] the instance itself
        # @raise [Hausgold::EntityNotFound] when not found
        def reload
          client.send("reload_#{remote_entity_name.underscore}!", self)
          self
        end

        # Saves the entity.
        #
        # If the entity is new, a instance gets created in the remote
        # application, otherwise the existing instance gets updated. +save+
        # always runs remote validations. If any of them fail the action is
        # cancelled and save returns false, and the record won't be saved.
        # +save+ also sets the updated_at attributes by convention to the
        # current time.
        #
        # There's a series of callbacks associated with save. If any of the
        # before_* callbacks throws :abort the action is cancelled and save
        # returns false.
        #
        # @yield [Hausgold::BaseEntity] the instance itself
        # @return [Boolean] whenever the saving was successful or not
        def save(&block)
          create_or_update(bang: false, &block)
        end

        # Saves the model.
        #
        # If the entity is new, a instance gets created in the remote
        # application, otherwise the existing instance gets updated.
        #
        # +save!+ always runs remote validations. If any of them fail
        # Hausgold::EntityInvalid gets raised, and the instance won't be saved.
        # +save!+ also sets the updated_at attributes by convention to the
        # current time.  There's a series of callbacks associated with +save!+.
        # If any of the before_* callbacks throws :abort the action is
        # cancelled and +save!+ raises Hausgold::EntityNotSaved.
        #
        # Unless an error is raised, returns true.
        #
        # @yield [Hausgold::BaseEntity] the instance itself
        # @return [Boolean] +true+ in case of success
        # @raise [Hausgold::EntityInvalid] when invalid data is present
        # @raise [Hausgold::EntityNotFound] when update does not found entity
        # @raise [Hausgold::EntityNotSaved] when already destroyed
        def save!(&block)
          create_or_update(bang: true, &block) || begin
            raise Hausgold::EntityNotSaved.new(nil, self, changes)
          end
        end

        # Deletes the instance at the remote application and freezes this
        # instance to reflect that no changes should be made (since they can't
        # be persisted). To enforce the object's before_destroy and
        # after_destroy callbacks use #destroy.
        #
        # @param args [Hash{Symbol => Mixed}] addition settings
        # @return [Hausgold::BaseEntity, false] whenever the deletion
        #   was successful
        def delete(**args)
          client.send(
            "delete_#{remote_entity_name.underscore}", self, **args
          ) || false
        end
        alias_method :destroy, :delete

        # Generate bang method variants
        bangers :delete, :destroy

        # Updates the attributes of the entity from the passed-in hash and
        # saves the entity. If the object is invalid, the saving will fail and
        # false will be returned. Also aliased as: update_attributes
        #
        # @param attributes [Hash{Symbol => Mixed}] the attributes to update
        # @return [Boolean] whenever the update was successful or not
        def update(attributes)
          assign_attributes(attributes)
          save
        end
        alias_method :update_attributes, :update

        # Updates its receiver just like update but calls save! instead of
        # save, so an exception is raised if the entity is invalid and saving
        # will fail. Also aliased as: update_attributes!
        #
        # @param attributes [Hash{Symbol => Mixed}] the attributes to update
        # @return [Boolean] +true+ in case of success
        # @raise [Hausgold::EntityInvalid] when invalid data is present
        # @raise [Hausgold::EntityNotFound] when update does not found entity
        # @raise [Hausgold::EntityNotSaved] when already destroyed
        def update!(attributes)
          assign_attributes(attributes)
          save!
        end
        alias_method :update_attributes!, :update!

        # Updates a single attribute and saves the entity. This is especially
        # useful for boolean flags on existing records. Also note that
        # validation is not skipped, callbacks are invoked, and updated_at is
        # updated if this property is available.  Updates all the attributes
        # that are dirty in this object.
        #
        # @param name [String, Symbol] the attribute name
        # @param value [Mixed] the new value to assign
        # @return [Boolean] whenever the update was successful or not
        def update_attribute(name, value)
          public_send("#{name}=", value)
          save
        end

        # Barely the same as +#update_attribute+ but raises on issues.
        #
        # @param name [String, Symbol] the attribute name
        # @param value [Mixed] the new value to assign
        # @return [Boolean] +true+ in case of success
        # @raise [Hausgold::EntityInvalid] when invalid data is present
        # @raise [Hausgold::EntityNotFound] when update does not found entity
        # @raise [Hausgold::EntityNotSaved] when already destroyed
        def update_attribute!(name, value)
          public_send("#{name}=", value)
          save!
        end

        private

        # Create or update the current entity instance. This will send the
        # corresponding requests to the underlying application to perform the
        # persistence.
        #
        # @param args [Hash{Symbol => Mixed}] additional settings
        # @yield [Hausgold::BaseEntity] after the persistence is performed
        # @return [Hausgold::BaseEntity, false]
        def create_or_update(**args)
          # Skip any further action, we're marked as destroyed
          return false if destroyed?

          # Run the create/update actions with the help of the client
          result = new_record? ? create_entity(**args) : update_entity(**args)
          # Run a block when given with +self+ as attribute
          yield(self) if block_given?
          # Return +true+, or +false+ in case of errors
          !result.nil?
        end

        # Generate abstract action methods which trigger the correct client
        # actions. When we call +create+ on a +Hausgold::Task+ instance, we
        # want to pass it through to the client as +create_task+.
        %i[create update].each do |method|
          class_eval <<-RUBY, __FILE__, __LINE__ + 1
            def #{method}_entity(**args)
              method = '#{method}_'.concat(remote_entity_name.underscore)
              client.send(method, self, **args)
            end
          RUBY
        end
      end

      class_methods do
        # Creates an object (or multiple objects) and saves it at the remote
        # application, if validations pass. The resulting object is returned
        # whether the object was saved successfully or not.  The attributes
        # parameter can be either a Hash or an Array of Hashes. These Hashes
        # describe the attributes on the objects that are to be created.
        #
        #   # Create a single new object
        #   Hausgold::Task.create(title: 'Do something', user_id: 'uuid')
        #
        #   # Create an Array of new objects
        #   Hausgold::Task.create([{ title: 'Task 1' }, { title: 'Task 2' }])
        #
        #   # Create a single object and pass it into a block to set other
        #   # attributes.
        #   Hausgold::Task.create(title: 'Do something') do |task|
        #     task.status = :resolved
        #   end
        #
        #   # Creating an Array of new objects using a block, where the block
        #   # is executed # for each object:
        #   Hausgold::Task.create([
        #     { title: 'Task 1' }, { title: 'Task 2' }
        #   ]) do |task|
        #     task.editable = false
        #   end
        #
        # @param attributes [nil, Hash{Symbol => Mixed}, Array<Hash>] the
        #   attributes to create the entity
        # @yield [Hausgold::BaseEntity] for each attribute set
        # @return [Hausgold::BaseEntity, Array<Hausgold::BaseEntity, false>]
        #   the corresponding entity/entity set
        def create(attributes = nil, &block)
          if attributes.is_a?(Array)
            attributes.collect { |attr| create(attr, &block) }
          else
            new(attributes, &block).tap(&:save)
          end
        end

        # Creates an object (or multiple objects) and saves at the remote
        # application, if validations pass. Raises a +Hausgold::EntityInvalid+
        # error if validations fail, unlike +#create+. The attributes parameter
        # can be either a Hash or an Array of Hashes. These describe which
        # attributes to be created on the object, or multiple objects when
        # given an Array of Hashes.
        #
        # @param attributes [nil, Hash{Symbol => Mixed}, Array<Hash>] the
        #   attributes to create the entity
        # @yield [Hausgold::BaseEntity] for each attribute set
        # @return [Hausgold::BaseEntity, Array<Hausgold::BaseEntity, false>]
        #   the corresponding entity/entity set
        def create!(attributes = nil, &block)
          if attributes.is_a?(Array)
            attributes.collect { |attr| create!(attr, &block) }
          else
            new(attributes, &block).tap(&:save!)
          end
        end

        # Updates an object (or multiple objects) and saves it at the remote
        # application, if validations pass. The resulting object is returned
        # whether the object was saved successfully to the database or not.
        #
        #   # Updates one entity
        #   Hausgold::Task.update('uuid', title: 'Buy milk',
        #                         location: 'Supermarket')
        #
        #   # Updates multiple records
        #   tasks = { 'uuid' => { title: 'Buy milk' },
        #             'other-uuid' => { title: 'Went to work' } }
        #   Hausgold::Task.update(tasks.keys, tasks.values)
        #
        # @param id [String] the entity identifier (UUID)
        # @param attributes [Hash{Symbol => Mixed}, Array<Hash>] the changes
        # @return [Hausgold::BaseEntity, Array<Hausgold::BaseEntity, false>]
        #   the updated entity/entities
        #
        # rubocop:disable Metrics/MethodLength because thats the bare minimum
        def update(id, attributes)
          if id.is_a?(Array)
            id.map { |one_id| find(one_id) }
              .each_with_index { |object, idx| object.update(attributes[idx]) }
          else
            if id.is_a? Hausgold::BaseEntity
              raise ArgumentError, 'You are passing an instance of ' \
                                   'Hausgold::BaseEntity to `update`. Please ' \
                                   'pass the id of the object by calling `.id`.'
            end
            find(id).tap { |object| object.update(attributes) }
          end
        end
        # rubocop:enable Metrics/MethodLength

        # Works the same way as +update+, but raises on errors.
        #
        # @param id [String] the entity identifier (UUID)
        # @param attributes [Hash{Symbol => Mixed}, Array<Hash>] the changes
        # @return [Hausgold::BaseEntity, Array<Hausgold::BaseEntity, false>]
        #   the updated entity/entities
        #
        # rubocop:disable Metrics/MethodLength because thats the bare minimum
        def update!(id, attributes)
          if id.is_a?(Array)
            id.map { |one_id| find(one_id) }
              .each_with_index { |object, idx| object.update!(attributes[idx]) }
          else
            if id.is_a? Hausgold::BaseEntity
              raise ArgumentError, 'You are passing an instance of ' \
                                   'Hausgold::BaseEntity to `update`. Please ' \
                                   'pass the id of the object by calling `.id`.'
            end
            find(id).tap { |object| object.update!(attributes) }
          end
        end
        # rubocop:enable Metrics/MethodLength

        # Deletes the entity by the +id+ argument. The object is instantiated
        # first, therefore all callbacks are fired off before the object is
        # deleted.  You can delete multiple entities at once by passing an
        # Array of ids.
        #
        #   # Delete a single entity
        #   Hausgold::Task.delete('uuid|gid')
        #
        #   # Delete multiple entities
        #   Hausgold::Task.delete(['uuid', 'gid', 'uuid'])
        #
        # @param id [String, Array<String>] the entity identifier (UUID)
        # @return [Hausgold::BaseEntity, Array<Hausgold::BaseEntity, false>]
        #   the deleted entity/entities
        def delete(id)
          if id.is_a?(Array)
            id.map { |one_id| new(id: one_id).delete }
          else
            new(id: id).delete
          end
        end
        alias_method :destroy, :delete

        # Works the same way as +delete+ but, raises on errors.
        #
        # @param id [String, Array<String>] the entity identifier (UUID)
        # @return [Hausgold::BaseEntity, Array<Hausgold::BaseEntity, false>]
        #   the deleted entity/entities
        def delete!(id)
          if id.is_a?(Array)
            id.map { |one_id| find(one_id).tap(&:delete!) }
          else
            find(id).tap(&:delete!)
          end
        end
        alias_method :destroy!, :delete!
      end
    end
    # rubocop:enable Metrics/ModuleLength
  end
end
