# frozen_string_literal: true

module Hausgold
  module PropertyApi
    # Some custom search profile actions.
    module SearchProfiles
      extend ActiveSupport::Concern

      included do
        # Fetch multiple entities by criteria. This method requires an already
        # persisted search profile (id) to search properties.
        #
        # @param criteria [Hausgold::SearchCriteria] the search criteria
        # @@param id [String] the search profile identifier
        # @param args [Hash{Symbol => Mixed}] additional options
        # @return [Array<Hausgold::Property>, nil] the entities, or +nil+
        #   on error
        #
        # rubocop:disable Metrics/AbcSize because of the search/find
        #   logic mixing
        def search_properties_via_profile(criteria, id:, **args)
          res = not_found unless (id = enforce_uuid(id))

          filters = criteria_to_filters(criteria)
          path = "/v1/search_profiles/#{id}/properties"

          res ||= search(path, filters, format(:search_profile, :search))

          decision(bang: args.fetch(:bang, false)) do |result|
            result.bang(&bang_entity(Hausgold::SearchProfile, res, id: id))
            result.good(&assign_entities(Hausgold::Property,
                                         res.body.properties))
            successful?(res)
          end
        end
        # rubocop:enable Metrics/AbcSize

        # Fetch multiple entities by criteria, in an adhoc fashion. This
        # method does not require an already persisted search profile to
        # search properties. You need to pass all the filters/attributes of the
        # search profile then the search is performed and the search profile
        # instance won't be persisted.
        #
        # @param criteria [Hausgold::SearchCriteria] the search criteria
        # @param args [Hash{Symbol => Mixed}] additional options
        # @return [Array<Hausgold::Property>, nil] the entities, or +nil+
        #   on error
        #
        # rubocop:disable Metrics/AbcSize because of the search/find
        #   logic mixing
        def search_properties_via_adhoc_profile(criteria, **args)
          path = '/v1/search_profiles/properties'

          # Build the full filters list, including the given attributes
          filters = criteria_to_filters(criteria)
                    .merge(args.fetch(:attributes, {})).compact.symbolize_keys

          res = search(path, filters, format(:search_profile, :search))

          decision(bang: args.fetch(:bang, false)) do |result|
            result.bang(&bang_entity(Hausgold::SearchProfile, res, **filters))
            result.good(&assign_entities(Hausgold::Property,
                                         res.body.properties))
            successful?(res)
          end
        end
        # rubocop:enable Metrics/AbcSize
      end
    end
  end
end
