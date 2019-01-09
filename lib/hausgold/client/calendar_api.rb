# frozen_string_literal: true

module Hausgold
  module Client
    # A high level client library for the Calendar API.
    class CalendarApi < Base
      # Include all the features
      include Hausgold::ClientUtils::GrapeCrud

      # Configure the application to use
      app 'calendar-api'

      # Define all the CRUD resources
      entity :appointment, '/v1/appointments'
      entity :task, '/v1/tasks'
      entity :timeframe, '/v1/timeframes'
    end
  end
end
