# frozen_string_literal: true

module Hausgold
  module EntityConcern
    # An ActiveRecord-like attribute management feature, with the exception
    # that the attributes are not generated through a schema file, but are
    # defined inline the entity class.
    #
    # rubocop:disable Metrics/ModuleLength because of ActiveSupport::Concern
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
            sanitizer = "sanitize_attr_#{key}".to_sym
            reader = methods.include?(sanitizer) ? sanitizer : key
            result = send(reader)
            result = result.attributes if result.respond_to? :attributes
            memo[key.to_s] = result
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

        # A wrapper for the +ActiveModel#assign_attributes+ method with support
        # for unmapped attributes. These attributes are put into the
        # +_unmapped+ struct and all the known attributes are assigned like
        # normal. This allows the client to be forward compatible with changing
        # APIs.
        #
        # @param struct [Hash{Mixed => Mixed}, RecursiveOpenStruct] the data
        #   to assign
        # @return [Mixed] the input data which was assigned
        def assign_attributes(struct = {})
          # Build a RecursiveOpenStruct and a simple hash from the given data
          struct, hash = sanitize_data(struct)
          # Initialize associations and map them accordingly
          struct, hash = initialize_associations(struct, hash)
          # Initialize attributes and map unknown ones and pass back the known
          known = initialize_attributes(struct, hash)
          # Mass assign the known attributes via ActiveModel
          super(known)
        end

        private

        # Explicitly convert the given struct to an +RecursiveOpenStruct+ and a
        # deep symbolized key copy for further usage.
        #
        # @param data [Hash{Mixed => Mixed}, RecursiveOpenStruct] the initial
        #   data
        # @return [Array<RecursiveOpenStruct, Hash{Symbol => Mixed}>] the
        #   left over data
        def sanitize_data(data = {})
          # Convert the given arguments to a recursive open struct,
          # when not already done
          data = ::RecursiveOpenStruct.new(data, recurse_over_arrays: true) \
            unless data.is_a? ::RecursiveOpenStruct
          # Symbolize all keys in deep (including hashes in arrays), while
          # converting back to an ordinary hash
          [data, data.to_h]
        end

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
          # Merge the previous unmapped struct and the given data
          self._unmapped = \
            ::RecursiveOpenStruct.new(_unmapped.to_h.merge(struct.to_h),
                                      recurse_over_arrays: true)
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

        # (Re-)Register attributes with strict type casts. This adds additional
        # reader methods as well as a writer with casted type.
        #
        # @param name [Symbol, String] the name of the attribute
        # @param type [Symbol] the type of the attribute
        # @param args [Hash{Symbol => Mixed}] additional options for the type
        def typed_attr(name, type, **args)
          send("typed_attr_#{type}", name, **args)
        end

        # rubocop:disable Lint/UselessAccessModifier because the first one
        #   is in the +included+ block, which is separated from the
        #   +class_methods+ block - looks like a rubocop bug
        private

        # rubocop:enable Lint/UselessAccessModifier

        # Register a casted boolean attribute, which allows +name?+ queries.
        # When you specify the +opposite+ argument, a negative checked reader
        # method is also added. (eg. public - private)
        #
        # @param name [Symbol, String] the name of the attribute
        # @param opposite [Symbol, String] the name of the opposite reader
        # @param _args [Hash{Symbol => Mixed}] additional options
        def typed_attr_boolean(name, opposite: nil, **_args)
          class_eval <<-RUBY, __FILE__, __LINE__ + 1
            def #{name}=(value)
              #{name}_will_change!
              @#{name} = ActiveModel::Type::Boolean.new.cast(value)
            end

            def #{name}?
              @#{name} == true
            end
          RUBY

          # When no opposite was specified, we dont generate a method for it
          return if opposite.nil?

          class_eval <<-RUBY, __FILE__, __LINE__ + 1
            def #{opposite}?
              !#{name}?
            end
          RUBY
        end

        # Register a casted symbol attribute.
        #
        # @param name [Symbol, String] the name of the attribute
        # @param _args [Hash{Symbol => Mixed}] additional options
        def typed_attr_symbol(name, **_args)
          class_eval <<-RUBY, __FILE__, __LINE__ + 1
            def #{name}=(value)
              #{name}_will_change!
              @#{name} = value.to_sym
            end
          RUBY
        end

        # Register a casted float attribute.
        #
        # @param name [Symbol, String] the name of the attribute
        # @param _args [Hash{Symbol => Mixed}] additional options
        def typed_attr_float(name, **_args)
          class_eval <<-RUBY, __FILE__, __LINE__ + 1
            def #{name}=(value)
              #{name}_will_change!
              value = value.to_f if value.is_a? Numeric
              value = ::Float::INFINITY if value == 'Infinity'

              @#{name} = value

              # @#{name} = value.finite? ? value : 'Infinity'
            end

            def sanitize_attr_#{name}
              return if @#{name}.nil?
              return 'Infinity' unless @#{name}.finite?

              @#{name}
            end
          RUBY
        end

        # Register a casted string inquirer attribute.
        #
        # @param name [Symbol, String] the name of the attribute
        # @param _args [Hash{Symbol => Mixed}] additional options
        def typed_attr_string_inquirer(name, **_args)
          class_eval <<-RUBY, __FILE__, __LINE__ + 1
            def #{name}=(value)
              #{name}_will_change!
              @#{name} = ActiveSupport::StringInquirer.new(value.to_s)
            end
          RUBY
        end

        # Register a casted array inquirer attribute.
        #
        # @param name [Symbol, String] the name of the attribute
        # @param _args [Hash{Symbol => Mixed}] additional options
        def typed_attr_array_inquirer(name, **_args)
          class_eval <<-RUBY, __FILE__, __LINE__ + 1
            def #{name}=(value)
              #{name}_will_change!
              value = [value] unless value.is_a? Array
              @#{name} = ActiveSupport::ArrayInquirer.new(value)
            end
          RUBY
        end

        # Register a casted array with +RecursiveOpenStruct+ elements.
        #
        # @param name [Symbol, String] the name of the attribute
        # @param _args [Hash{Symbol => Mixed}] additional options
        def typed_attr_recursive_open_struct_array(name, **_args)
          class_eval <<-RUBY, __FILE__, __LINE__ + 1
            def #{name}=(value)
              #{name}_will_change!
              value = [value] unless value.is_a? Array
              @#{name} = value.map do |item|
                RecursiveOpenStruct.new(item, recurse_over_arrays: true)
              end
            end
          RUBY
        end
      end
    end
    # rubocop:enable Metrics/ModuleLength
  end
end
