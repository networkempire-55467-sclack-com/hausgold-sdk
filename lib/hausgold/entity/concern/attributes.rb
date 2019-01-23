# frozen_string_literal: true

module Hausgold
  module EntityConcern
    # An ActiveRecord-like attribute management feature, with the exception
    # that the attributes are not generated through a schema file, but are
    # defined inline the entity class.
    module Attributes
      extend ActiveSupport::Concern

      included do
        # Collect all registed attribute names as symbols
        class_attribute :attribute_names

        # Export all attributes as data hash, as requested by the ActiveModel
        # API.
        #
        # @return [Hash{String => Mixed}] the attribute data
        def attributes
          attribute_names.each_with_object({}) do |key, memo|
            memo[key.to_s] = send(key)
          end
        end

        # Clear all changes of the current instance and all associated entity
        # instances in a recursive manner. This is useful for per-client usage,
        # directly after an entity is fetched, build and passed back to the
        # user. In this case the entity should be clean. This method allows
        # chaining.
        #
        # @return [Hausgold::BaseEntity] pass back ourself
        def clear_changes
          # Clear the top level
          send(:clear_changes_information)
          # Stop if there are no associations configured
          return unless respond_to? :associations

          # Clear associations
          associations.keys.each do |attribute|
            [send(attribute)].flatten.each do |entity|
              next unless entity.respond_to? :clear_changes

              entity.clear_changes
            end
          end
          # Passback ourself for chaining
          self
        end

        private

        # Process the given data by separating the known from the unknown
        # attributes. The unknown attributes are collected on the +_unmapped+
        # variable for later access. This allows the entities to be
        # forward-compatible on the application HTTP responses in case of
        # additions.
        #
        # @param struct [RecursiveOpenStruct] all the data as struct
        # @param hash [Hash{Symbol => Mixed}] all the data as hash
        # @return [Hash{Symbol => Mixed}] the known attributes
        def initialize_attributes(struct, hash)
          # Substract known keys, to move them to the +_unmapped+ variable
          attribute_names.each { |key| struct.delete_field(key) }
          self._unmapped = struct
          # Allow mass assignment of known attributes
          hash.slice(*attribute_names)
        end
      end

      class_methods do
        # Initialize the attributes structures on an inherited class.
        #
        # @param child_class [Class] the child class which inherits us
        def inherited_setup_attributes(child_class)
          child_class.attribute_names = []
        end

        # Register tracked attributes of the entity. This adds the attributes
        # to the +Class.attribute_names+ collection, generates getters and
        # setters as well sets up the dirty-tracking of these attributes.
        #
        # @param args [Array<Symbol>] the attributes to register
        def tracked_attr(*args)
          # Register the attribute names, for easy access
          self.attribute_names += args
          # Define getters/setters
          attr_reader(*args)
          args.each do |arg|
            class_eval <<-RUBY, __FILE__, __LINE__ + 1
              def #{arg}=(value)
                #{arg}_will_change!
                @#{arg} = value
              end
            RUBY
          end
          # Register the attributes for ActiveModel
          define_attribute_methods(*args)
        end
      end
    end
  end
end
