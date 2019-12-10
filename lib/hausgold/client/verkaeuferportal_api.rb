# frozen_string_literal: true

module Hausgold
  module Client
    # A high level client library for the Verkaeuferportal API.
    class VerkaeuferportalApi < Base
      # Include all the features
      include Hausgold::ClientUtils::GrapeCrud
      include Hausgold::ClientUtils::FactoryBotInstrumentation
      include Hausgold::VerkaeuferportalApi::Users

      # Configure the application to use
      app 'verkaeuferportal-api'

      # Define all the CRUD resources
      entity :user, '/v1/users', class_name: Hausgold::Customer

      # Define all instrumentation entities
      factory_i13n :customer, factory: :user, class_name: Hausgold::Customer
    end
  end
end
