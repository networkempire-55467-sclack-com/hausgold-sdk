# frozen_string_literal: true

module Hausgold
  # A HAUSGOLD ecosystem broker account is a specialization of its identity
  # (+User+). A broker is located at the Maklerportal API and contains
  # personal data like first- and lastnames. All the user objects
  # (+identity-api/User+, +maklerportal-api/User+, +verkaeuferportal-api/User+,
  # etc) share the same id (UUID) to signalize they belong together, but differ
  # on the gid (Global Id). Furthermore, the +maklerportal-api/User+ is
  # aliased here to be a +Hausgold::Broker+ to distinguish the entities on
  # client sides easily.
  class Broker < BaseEntity
    # The low level client
    client :maklerportal_api

    # Mapped and tracked attributes
    tracked_attr :id, :gid, :customer_id, :email, :contact_email,
                 :unconfirmed_email, :first_name, :last_name, :gender, :locale,
                 :contact_id, :contact_phone, :created_at, :updated_at,
                 :confirmed_at, :deactivated_at, :password

    # Define attribute types for casting
    typed_attr :gender, :string_inquirer
    typed_attr :locale, :symbol
  end
end
