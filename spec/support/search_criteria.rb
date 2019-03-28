# frozen_string_literal: true

# Create a new search criteria instance for testing.
#
# @param max_per_page [Integer] the max per page size
# @param entity [Class] the entity class, defaults to +Hausgold::User+
# @return [Hausgold::SearchCriteria] the fresh criteria
def criteria(max_per_page: 250, entity: Hausgold::User)
  Hausgold::SearchCriteria.new(entity).tap do |obj|
    obj.max_per_page = max_per_page
  end
end
