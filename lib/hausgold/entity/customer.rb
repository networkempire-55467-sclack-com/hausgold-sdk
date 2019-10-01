# frozen_string_literal: true

module Hausgold
  # A HAUSGOLD ecosystem customer account is a specialization of its identity
  # (+User+). A customer is located at the Kundenportal API and contains
  # personal data like first- and lastnames. All the user objects
  # (+identity-api/User+, +maklerportal-api/User+, +verkaeuferportal-api/User+,
  # etc) share the same id (UUID) to signalize they belong together, but differ
  # on the gid (Global Id). Furthermore, the +verkaeuferportal-api/User+ is
  # aliased here to be a +Hausgold::Customer+ to distinguish the entities on
  # client sides easily.
  class Customer < BaseEntity
    # The low level client
    client :verkaeuferportal_api

    # Mapped and tracked attributes
    tracked_attr :id, :gid, :email, :first_name, :last_name, :gender, :mobile,
                 :phone, :created_at, :updated_at, :status, :password

    # Define attribute types for casting
    typed_attr :gender, :string_inquirer

    # Associations
    has_one :address, persist: true

    # Notify a customer/user about a created property.
    #
    # @deprecated This is deprecated by default and will be dropped
    #   in future SDK releases in favor of direct message bus consumption on
    #   the Verkaeuferportal API.
    #
    # @param args [Hash{Symbol => Mixed}] additional options
    # @return [Hausgold::Customer] the current customer instance
    def property_created_notification(property_id:, **args)
      params = { property_id: property_id }.merge(args)
      client.user_notify_property_created(self, **params)
    end

    # Generate bang method variants
    bangers :property_created_notification
  end
end
