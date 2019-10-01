# frozen_string_literal: true

module Hausgold
  module EntityConcern
    # Allow to work with Global Ids easily on class and instance levels.
    module GlobalId
      extend ActiveSupport::Concern

      included do
        # Build a new Global Id URI instance for the entity instance.
        #
        # @param args [Hash{Symbol => Mixed}] additional URI parameters
        # @return [URI::GID] the Global Id of the entity
        def to_gid(**args)
          self.class.to_gid(id, **args)
        end
      end

      class_methods do
        # Build a new Global Id URI instance for the entity.
        #
        # @param id [String] the entity identifier
        # @param args [Hash{Symbol => Mixed}] additional URI parameters
        # @return [URI::GID] the Global Id of the entity
        def to_gid(id, **args)
          Hausgold.build_gid(client_class.app_name,
                             remote_entity_name,
                             id,
                             **args)
        end
      end
    end
  end
end
