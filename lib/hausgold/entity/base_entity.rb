# frozen_string_literal: true

module Hausgold
  # The base entity, with a lot of known ActiveRecord/ActiveModel features.
  class BaseEntity
    include ActiveModel::Model
    include ActiveModel::Dirty
    include ActiveModel::Serialization
    extend ActiveModel::Callbacks

    include Hausgold::Utils::Bangers
    include Hausgold::EntityConcern::Attributes
    include Hausgold::EntityConcern::Associations
    include Hausgold::EntityConcern::Client
    include Hausgold::EntityConcern::Query
    include Hausgold::EntityConcern::Persistence

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
      # Convert the given arguments to a recursive open struct,
      # when not already done
      struct = ::RecursiveOpenStruct.new(struct, recurse_over_arrays: true) \
        unless struct.is_a? ::RecursiveOpenStruct
      # Symbolize all keys in deep (including hashes in arrays), while
      # converting back to an ordinary hash
      hash = struct.to_h
      # Initialize associations and map them accordingly
      struct, hash = initialize_associations(struct, hash)
      # Initialize attributes and map unknown ones and pass back the known
      known = initialize_attributes(struct, hash)
      # Mass assign the known attributes via ActiveModel
      super(known)
      # Follow the ActiveRecord API
      yield self if block_given?
    end

    # Initialize the class we were inherited to. We trigger all our methods
    # which start with +inherited_setup_+ to allow per-concern/feature based
    # initialization after BaseEntity inheritance.
    #
    # @param child_class [Class] the child class which inherits us
    def self.inherited(child_class)
      match = ->(sym) { sym.to_s.start_with? 'inherited_setup_' }
      trigger = ->(sym) { send(sym, child_class) }
      methods.select(&match).each(&trigger)
    end

    # Returns the bare entity name of the current instance.
    #
    # @return [String] the bare entity name
    def entity_name
      self.class.name.remove(/^Hausgold::/)
    end
  end
end
