# frozen_string_literal: true

module Hausgold
  # Builds the foundation for intermediate search criteria for all clients. We
  # support a filter chaining interface like ActiveRecord to provide a powerful
  # method to build queries.
  class SearchCriteria
    attr_accessor :max_per_page, :client_method_args
    attr_reader :entity_class, :client_method

    include Hausgold::Search::Settings
    include Hausgold::Search::Paging
    include Hausgold::Search::Executor

    # Create a new search criteria which takes all conditions like fitlers,
    # limits and offsets. The search criteria requires the resulting entity
    # class to manage the requests by the entity-client.
    #
    # @param entity_class [Class] the resulting entity class for the search
    # @param client_method [String, Symbol, nil] the client method to use
    #   for search, by default it is build by convention to
    #   +search_#{entity_class.remote_entity_name} (snake_case, plural)
    # @param client_method_args [Hash{Mixed => Mixed}] additional arguments
    #   for the client method, they will be merged with runtime arguments
    def initialize(entity_class, client_method = nil, client_method_args = {})
      @max_per_page = 250
      @entity_class = entity_class
      @client_method = client_method
      @client_method ||= "search_#{entity_class.remote_entity_name
                                               .underscore.pluralize}"
      @client_method_args = client_method_args
    end

    # Print a nice but lean criteria information string for the current
    # instance.
    #
    # @return [String] the inspection output
    def inspect
      "#<#{self.class.name} filters=#{where}, offset=#{offset}, " \
        "limit=#{limit}, sort=#{sort}, pages=#{pages}, " \
        "per_page=#{per_page}, slice=#{result_slice}>"
    end
  end
end
