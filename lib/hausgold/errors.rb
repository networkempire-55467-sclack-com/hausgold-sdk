# frozen_string_literal: true

module Hausgold
  # Generic entity exception class.
  class EntityError < StandardError
  end

  # A common error class to signalize missing functionality.
  class NotImplementedError < StandardError
    # Create a new instance of the error.
    #
    # @param class_name [Constant] the affected class name
    # @param method [Symbol, String] the missing method
    def initialize(class_name, method)
      class_name = class_name.class.name unless class_name.is_a? Class
      super("#{class_name}##{method} not yet implemented")
    end
  end

  # Generic request/response exception class.
  class RequestError < StandardError
    attr_reader :response

    # Create a new instance of the error.
    #
    # @param message [String] the error message
    # @param response [Faraday::Response] the response
    def initialize(message = nil, response = nil)
      @response = response
      message ||= response.body.message if response.body.respond_to? :message

      super(message)
    end
  end

  # Raised when the authentication request failed.
  class AuthenticationError < RequestError; end

  # Raised when an entity was not found while searching/getting.
  class EntityNotFound < EntityError
    attr_reader :entity, :criteria

    # Create a new instance of the error.
    #
    # @param message [String] the error message
    # @param entity [Hausgold::BaseEntity] the entity which was not found
    # @param criteria [Hash{Symbol => Mixed}] the search/find criteria
    def initialize(message = nil, entity = nil, criteria = {})
      @entity = entity
      @criteria = criteria
      message ||= "Couldn't find #{entity} with #{criteria.inspect}"

      super(message)
    end
  end

  # Raised when the record is invalid, due to a response.
  class EntityInvalid < EntityError; end

  # Raised when the record is not saved for any reason.
  class EntityNotSaved < EntityNotFound
    # Create a new instance of the error.
    #
    # @param message [String] the error message
    # @param entity [Hausgold::BaseEntity] the entity which was not found
    # @param criteria [Hash{Symbol => Mixed}] the search/find criteria
    def initialize(message = nil, entity = nil, criteria = {})
      message ||= "Failed to save the entity #{entity} with #{criteria.inspect}"
      super(message, entity, criteria)
    end
  end
end
