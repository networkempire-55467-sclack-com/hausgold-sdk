# frozen_string_literal: true

module Hausgold
  module EntityConcern
    # Allow simple association mappings like ActiveRecord supports (eg.
    # +has_one+, +has_many+).
    module Associations
      extend ActiveSupport::Concern

      included do
        # Collect all the registed association configurations
        class_attribute :associations

        private

        # Map the registered associations to the actual instance.
        #
        # @param struct [RecursiveOpenStruct] all the data as struct
        # @param hash [Hash{Symbol => Mixed}] all the data as hash
        # @return [Array<RecursiveOpenStruct, Hash{Symbol => Mixed}>] the
        #   left over data
        def initialize_associations(struct, hash)
          # Walk through the configured associations and set them up
          associations.each_with_object([struct, hash]) do |cur, memo|
            opts = cur.last
            send("map_#{opts[:type]}_association", cur.first, opts, *memo)
          end
        end

        # Map an simple has_one association to the resulting entity attribute.
        # The source key is stripped off according to the association
        # definition.
        #
        # @param attribute [Symbol] the name of the destination attribute
        # @param opts [Hash{Symbol => Mixed}] the association definition
        # @param struct [RecursiveOpenStruct] all the data as struct
        # @param hash [Hash{Symbol => Mixed}] all the data as hash
        # @return [Array<RecursiveOpenStruct, Hash{Symbol => Mixed}>] the
        #   left over data
        def map_has_one_association(attribute, opts, struct, hash)
          # Early exit when the source key is missing on the given data
          key = opts[:from]
          return [struct, hash] unless hash.key? key

          # Instantiate a new entity from the association
          send("#{attribute}=", opts[:class_name].new(hash[key]))

          # Strip off the source key, because we mapped it
          struct.delete_field(key)
          hash = hash.delete(key)
          # Pass back the new data
          [struct, hash]
        end
      end

      # rubocop:disable Naming/PredicateName because we follow
      #   known naming conventions
      class_methods do
        # Initialize the associations structures on an inherited class.
        #
        # @param child_class [Class] the child class which inherits us
        def inherited_setup_associations(child_class)
          child_class.associations = {}
        end

        # Define a simple +has_one+ association.
        #
        # Options
        # * +:class_name+ - the entity class to use, otherwise it is guessed
        # * +:from+ - take the data from this attribute
        # * +:persist+ - whenever to send the association
        #                attributes (default: false)
        #
        # @param entity [String, Symbol] the attribute/entity name
        # @param args [Hash{Symbol => Mixed}] additional options
        def has_one(entity, **args)
          # Sanitize options
          entity = entity.to_sym
          opts = { class_name: nil, from: entity, persist: false } \
                 .merge(args).merge(type: :has_one)
          # Resolve the given entity to a class name, when no explicit class
          # name was given via options
          if opts[:class_name].nil?
            opts[:class_name] = \
              entity.to_s.camelcase.prepend('Hausgold::').constantize
          end
          # Register the association
          associations[entity] = opts
          # Generate getters and setters
          attr_accessor entity
          # Add the entity to the tracked attributes if it should be persisted
          tracked_attr entity if opts[:persist]
        end
      end
      # rubocop:enable Naming/PredicateName
    end
  end
end
