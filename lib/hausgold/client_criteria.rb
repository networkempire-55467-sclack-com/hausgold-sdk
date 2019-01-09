# frozen_string_literal: true

module Hausgold
  # Builds the foundation for intermediate search criteria for all clients. We
  # support a filter chaining interface like ActiveRecord to provide a powerful
  # method to build queries.
  class ClientCriteria
    attr_accessor :entity_class

    def initialize(entity_class)
      self.entity_class = entity_class
    end

    def criteria
      @criteria ||= { conditions: {} }
    end

    def find_by(**args); end

    def all; end

    def where(**args); end

    def limit(count); end

    def offset(count); end

    # def where(**args)
    #   criteria[:conditions].merge!(**args)
    #   self
    # end

    def each(&block)
      # @entity_class.client.find(
      #   criteria[:conditions], {:limit => criteria[:limit]}
      # ).each(&block)
    end
  end
end
