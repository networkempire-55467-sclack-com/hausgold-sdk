# frozen_string_literal: true

module Hausgold
  # The base entity, with a lot of known ActiveRecord/ActiveModel features.
  class BaseEntity
    include ActiveModel::Model
    include ActiveModel::Dirty
    include ActiveModel::Serialization

    include Hausgold::Utils::Bangers

    # Additional singleton class functionalities
    class << self
      include Hausgold::Utils::Bangers
    end

    include Hausgold::EntityConcern::Callbacks
    include Hausgold::EntityConcern::Attributes
    include Hausgold::EntityConcern::Associations
    include Hausgold::EntityConcern::Client
    include Hausgold::EntityConcern::Query
    include Hausgold::EntityConcern::Persistence
    include Hausgold::EntityConcern::GlobalId

    # We collect all unknown attributes instead of raising while creating a new
    # instance. The unknown attributes are wrapped inside a
    # +RecursiveOpenStruct+ to ease the accessibility. This also allows us to
    # handle responses in a forward-compatible way.
    attr_accessor :_unmapped

    # Create a new instance of an entity with a lot of known
    # ActiveRecord/ActiveModel features.
    #
    # @param struct [Hash{Mixed => Mixed}, RecursiveOpenStruct] the initial data
    # @return [Hausgold::BaseEntity] a compatible instance
    # @yield [Hausgold::BaseEntity] the entity itself in the end
    def initialize(struct = {})
      # Set the initial unmapped struct
      self._unmapped = RecursiveOpenStruct.new
      # Build a RecursiveOpenStruct and a simple hash from the given data
      struct, hash = sanitize_data(struct)
      # Initialize associations and map them accordingly
      struct, hash = initialize_associations(struct, hash)
      # Initialize attributes and map unknown ones and pass back the known
      known = initialize_attributes(struct, hash)
      # Mass assign the known attributes via ActiveModel
      super(known)
      # Follow the ActiveRecord API
      yield self if block_given?
      # Run the initializer callbacks
      _run_initialize_callbacks
    end

    # Returns the bare entity name of the current instance.
    #
    # @return [String] the bare entity name
    def entity_name
      self.class.entity_name
    end

    # Returns the bare remote entity name of the current instance. This is
    # mostly the same as +#entity_name+ but when the client configured some
    # class alisases (masquerading) we return the actual remote entity name.
    #
    # @return [String] the bare remote entity name
    def remote_entity_name
      self.class.remote_entity_name
    end

    class << self
      # Initialize the class we were inherited to. We trigger all our methods
      # which start with +inherited_setup_+ to allow per-concern/feature based
      # initialization after BaseEntity inheritance.
      #
      # @param child_class [Class] the child class which inherits us
      def inherited(child_class)
        match = ->(sym) { sym.to_s.start_with? 'inherited_setup_' }
        trigger = ->(sym) { send(sym, child_class) }
        methods.select(&match).each(&trigger)
      end

      # Returns the bare entity name of the current instance.
      #
      # @return [String] the bare entity name
      def entity_name
        name.remove(/^Hausgold::/)
      end

      # Returns the bare remote entity name of the current instance. This is
      # mostly the same as +#entity_name+ but when the client configured some
      # class alisases (masquerading) we return the actual remote entity name.
      #
      # @return [String] the bare remote entity name
      def remote_entity_name
        client_class
          .entities
          .find { |_, opts| opts[:class_name] == self }
          .first
          .to_s
          .camelize
      end
    end
  end
end
