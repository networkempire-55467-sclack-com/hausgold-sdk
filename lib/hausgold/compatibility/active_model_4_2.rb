# frozen_string_literal: true

# Unfortunately ActiveModel 4.2 does not ship the AttributeAssignment concern.
# This was part of ActiveRecord back then, so we just bundle it and load it
# when required. This just affect mass attribute assignment and the
# corresponding initializer.
#
# The contents of this file are grabbed from ActiveModel 5.2.2:
#   * http://bit.ly/2RYGOG5
#   * http://bit.ly/2T7w1q9

require 'active_support/core_ext/hash/keys'

module ActiveModel
  module AttributeAssignment
    include ActiveModel::ForbiddenAttributesProtection

    # Allows you to set all the attributes by passing in a hash of attributes
    # with keys matching the attribute names.
    #
    # If the passed hash responds to +permitted?+ method and the return value
    # of this method is +false+ an +ActiveModel::ForbiddenAttributesError+
    # exception is raised.
    #
    #   class Cat
    #     include ActiveModel::AttributeAssignment
    #     attr_accessor :name, :status
    #   end
    #
    #   cat = Cat.new
    #   cat.assign_attributes(name: "Gorby", status: "yawning")
    #   cat.name # => 'Gorby'
    #   cat.status # => 'yawning'
    #   cat.assign_attributes(status: "sleeping")
    #   cat.name # => 'Gorby'
    #   cat.status # => 'sleeping'
    def assign_attributes(new_attributes)
      unless new_attributes.respond_to?(:stringify_keys)
        raise ArgumentError, 'When assigning attributes, you must ' \
                             'pass a hash as an argument.'
      end
      return if new_attributes.empty?

      attributes = new_attributes.stringify_keys
      _assign_attributes(sanitize_for_mass_assignment(attributes))
    end

    alias attributes= assign_attributes

    private

    def _assign_attributes(attributes)
      attributes.each do |k, v|
        _assign_attribute(k, v)
      end
    end

    def _assign_attribute(k, v)
      setter = :"#{k}="
      if respond_to?(setter)
        public_send(setter, v)
      else
        raise UnknownAttributeError.new(self, k)
      end
    end
  end
end

module ActiveModel
  module Model
    include ActiveModel::AttributeAssignment

    # Initializes a new model with the given +params+.
    #
    #   class Person
    #     include ActiveModel::Model
    #     attr_accessor :name, :age
    #   end
    #
    #   person = Person.new(name: 'bob', age: '18')
    #   person.name # => "bob"
    #   person.age  # => "18"
    def initialize(attributes = {})
      assign_attributes(attributes) if attributes

      super()
    end
  end
end

module ActiveModel
  module Type
    # == Active \Model \Type \Boolean
    #
    # A class that behaves like a boolean type, including rules for coercion of
    # user input.
    #
    # === Coercion
    #
    # Values set from user input will first be coerced into the appropriate
    # ruby type.  Coercion behavior is roughly mapped to Ruby's boolean
    # semantics.
    #
    # - "false", "f" , "0", +0+ or any other value in +FALSE_VALUES+
    #   will be coerced to +false+
    # - Empty strings are coerced to +nil+
    # - All other values will be coerced to +true+
    class Boolean
      FALSE_VALUES = [false, 0, "0", "f", "F", "false",
                      "FALSE", "off", "OFF"].to_set

      def type # :nodoc:
        :boolean
      end

      def serialize(value) # :nodoc:
        cast(value)
      end

      def cast(value)
        cast_value(value) unless value.nil?
      end

      private

        def cast_value(value)
          if value == ""
            nil
          else
            !FALSE_VALUES.include?(value)
          end
        end
    end
  end
end
