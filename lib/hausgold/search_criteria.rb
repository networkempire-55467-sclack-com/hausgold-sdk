# frozen_string_literal: true

module Hausgold
  # Builds the foundation for intermediate search criteria for all clients. We
  # support a filter chaining interface like ActiveRecord to provide a powerful
  # method to build queries.
  class SearchCriteria
    attr_accessor :max_per_page
    attr_reader :entity_class

    include Hausgold::Search::Settings
    include Hausgold::Search::Paging
    include Hausgold::Search::Executor

    # Create a new search criteria which takes all conditions like fitlers,
    # limits and offsets. The search criteria requires the resulting entity
    # class to manage the requests by the entity-client.
    #
    # @param entity_class [Class] the resulting entity class for the search
    def initialize(entity_class)
      @entity_class = entity_class
      @max_per_page = 250
    end

    # Print a nice but lean criteria information string for the current
    # instance.
    #
    # @return [String] the inspection output
    def inspect
      "#<#{self.class.name} filters=#{where}, offset=#{offset}, " \
        "limit=#{limit}, pages=#{pages}, per_page=#{per_page}, " \
        "slice=#{result_slice}>"
    end
  end
end
