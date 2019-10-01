# frozen_string_literal: true

module Hausgold
  # A common address entity without direct persistence on the ecosystem. It can
  # be included as associations on other entities to track address data.
  class Address < BaseEntity
    # Mapped and tracked attributes
    tracked_attr :street, :street_addition, :city, :zipcode, :country_code

    # Define attribute types for casting
    typed_attr :country_code, :string_inquirer
  end
end
