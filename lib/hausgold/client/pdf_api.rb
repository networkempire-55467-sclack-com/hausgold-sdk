# frozen_string_literal: true

module Hausgold
  module Client
    # A high level client library for the PDF API.
    class PdfApi < Base
      # Include all the features
      include Hausgold::ClientUtils::GrapeCrud
      include Hausgold::PdfApi::Downloads

      # The PDF API uses hashed URLs as identifiers
      disable_forced_uuid_ids

      # Configure the application to use
      app 'pdf-api'

      # Define all the CRUD resources
      entity :pdf, '/v1/pdf', only: %i[create find reload]
    end
  end
end
