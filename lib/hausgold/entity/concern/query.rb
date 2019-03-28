# frozen_string_literal: true

module Hausgold
  module EntityConcern
    # Allow entities to be queried like regular ActiveRecord entities. Not all
    # known methods are supported, but the common ones which fit to
    # API-compatible requests.
    module Query
      extend ActiveSupport::Concern

      class_methods do
        include Hausgold::Utils::Bangers

        # Find a single entity by its identifier (id UUID or Global Id). In
        # case an gid was passed we utilize the regular gid-locating tooling
        # and check afterwards for the correct entity class.
        #
        # @param id [String] the identifier to use
        # @return [Hausgold::SearchCriteria] the criteria object
        # @raise [Hausgold::EntityNotFound]
        def find(id)
          # In case we have to deal with non-GIDs, we convert them
          id = Hausgold.build_gid(client_class.app_name, self, id) \
            unless Hausgold::Utils::Matchers.gid?(id)
          # Try to locate the entity with our lovely base client locater
          Hausgold.locate(id).tap do |entity|
            # When we found something else than expected, we raise
            unless entity.class == self
              msg = "Found #{entity.class} instead of #{self}"
              raise Hausgold::EntityNotFound.new(msg, self, id)
            end
          end
        end

        # Search for a single entity with the given criteria.
        #
        # @param args [Hash{Symbol => Mixed}] the search criteria
        # @return [Hausgold::BaseEntity, nil] the found entity
        def find_by(**args)
          Hausgold::SearchCriteria.new(self).find_by(**args)
        end
        bangers :find_by

        # Check if a single entity with the given criteria exists.
        #
        # @param args [Hash{Symbol => Mixed}] the search criteria
        # @return [Boolean] whenever the search was successful or not
        def exists?(**args)
          find_by(args).present?
        end

        # Signalize that we want to retrieve the whole result set via
        # pagination.
        #
        # @return [Hausgold::SearchCriteria] the criteria object
        def all
          Hausgold::SearchCriteria.new(self).all
        end

        # Define a condition list (conjunction only) for the search.
        #
        # @param args [Hash{Symbol => Mixed}] the search criteria
        # @return [Hausgold::SearchCriteria] the criteria object
        def where(**args)
          Hausgold::SearchCriteria.new(self).where(**args)
        end

        # Define the limit of result elements.
        #
        # @param count [Integer] the limit to pass
        # @return [Hausgold::SearchCriteria] the criteria object
        def limit(count)
          Hausgold::SearchCriteria.new(self).limit(count)
        end

        # Define an offset to the result.
        #
        # @param count [Integer] the offset to pass
        # @return [Hausgold::SearchCriteria] the criteria object
        def offset(count)
          Hausgold::SearchCriteria.new(self).offset(count)
        end
      end
    end
  end
end
