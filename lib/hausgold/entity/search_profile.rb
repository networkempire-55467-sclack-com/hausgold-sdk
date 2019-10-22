# frozen_string_literal: true

module Hausgold
  # The HAUSGOLD search profile is a loosely coupled entity to formulate a
  # complex set of search criteria for the property search.
  class SearchProfile < BaseEntity
    # The low level client
    client :property_api

    # Mapped and tracked attributes
    tracked_attr :id, :gid, :user_id, :usages, :property_types,
                 :property_subtypes, :city, :zipcode, :perimeter, :price_from,
                 :price_to, :year_of_construction_from,
                 :year_of_construction_to, :amount_rooms_from,
                 :amount_rooms_to, :living_space_from, :living_space_to,
                 :land_size_from, :land_size_to, :created_at, :updated_at

    # Define attribute types for casting
    typed_attr :usages, :array_inquirer
    typed_attr :property_types, :array_inquirer
    typed_attr :property_subtypes, :array_inquirer

    typed_attr :perimeter, :float
    typed_attr :price_from, :float
    typed_attr :price_to, :float
    typed_attr :year_of_construction_from, :float
    typed_attr :year_of_construction_to, :float
    typed_attr :amount_rooms_from, :float
    typed_attr :amount_rooms_to, :float
    typed_attr :living_space_from, :float
    typed_attr :living_space_to, :float
    typed_attr :land_size_from, :float
    typed_attr :land_size_to, :float
  end
end
