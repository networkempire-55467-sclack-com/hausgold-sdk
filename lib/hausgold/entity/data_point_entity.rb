# frozen_string_literal: true

module Hausgold
  # The HAUSGOLD ecosystem features data point entities for the permission
  # handling per time line. This is simple ACL system which may be changed in
  # mid-term future. But for now with the help of the data point entity one can
  # reconfigure the permissions of a time series on demand.
  class DataPointEntity < BaseEntity
    # The low level client
    client :analytic_api

    # Mapped and tracked attributes
    tracked_attr :id, :gid, :permissions, :created_at, :updated_at

    # NOTE: This method overwrites the +delete+ method of the BaseEntity.
    # Since the ID of the Entity is not known to other services and the
    # Analytic API performs an create_or_update of the given entity. This
    # is a workaround to get the ID of the Entity.
    #
    # @param args [Hash{Symbol => Mixed}] addition settings
    # @return [Hausgold::DataPointEntity, false] whenever the deletion
    #   was successful
    def delete(**args)
      save &&
        client.delete_data_point_entity(self, **args) || false
    end

    # Bang variant of +delete+.
    #
    # @param args [Hash{Symbol => Mixed}] addition settings
    # @return [Hausgold::DataPointEntity, false] whenever the deletion
    #   was successful
    def delete!(**args)
      save! &&
        client.delete_data_point_entity(self, **args) || false
    end
  end
end
