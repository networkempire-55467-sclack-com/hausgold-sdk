# frozen_string_literal: true

module Hausgold
  module Search
    # The search settings interface.
    #
    # rubocop:disable Metrics/BlockLength because of ActiveSupport::Concern
    module Settings
      extend ActiveSupport::Concern

      included do
        # The default criteria settings
        DEFAULT_CRITERIA = {
          filters: {},
          limit: 0,
          offset: 0,
          raise_errors: false
        }.freeze

        # Get the criteria hash which holds all settings.
        #
        # @return [Hash{Symbol => Mixed}] the criteria settings
        def criteria
          @criteria ||= DEFAULT_CRITERIA.deep_dup
        end

        # Clear out all previous criteria settings and pass back the criteria
        # instance for method chaining.
        #
        # @return [Hausgold::SearchCriteria] the current criteria instance
        def all
          @criteria = DEFAULT_CRITERIA.deep_dup
          self
        end

        # Set the new given limit, otherwise return the current set limit when
        # the +count+ is nil. When a new limit is set we return the criteria
        # instance for method chaining.
        #
        # @param count [Integer, nil] the new limit to set
        # @return [Hausgold::SearchCriteria, Integer] the current criteria
        #   instance or the current set limit
        def limit(count = nil)
          return criteria[:limit] if count.nil?

          criteria[:limit] = count
          self
        end

        # Set the new given offset, otherwise return the current set offset
        # when the +count+ is nil. When a new offset is set we return the
        # criteria instance for method chaining.
        #
        # @param count [Integer, nil] the new offset to set
        # @return [Hausgold::SearchCriteria, Integer] the current criteria
        #   instance or the current set offset
        def offset(count = nil)
          return criteria[:offset] if count.nil?

          criteria[:offset] = count
          self
        end

        # Merge the given filters to a conjunction set. When no filters are
        # given we return the current filter conjunction set. When new filters
        # are given we return the criteria instance for method chaining.
        #
        # @param args [Hash{Symbol => Mixed}, nil] the additional filters to set
        # @return [Hausgold::SearchCriteria, Hash{Symbol => Mixed}] the current
        #   criteria instance or the current set offset
        def where(**args)
          return criteria[:filters] if args.empty?

          criteria[:filters].merge!(**args)
          self
        end

        # Set the criteria settings to find a single result by the given
        # filters. This does not overwrite previously set filters. The new
        # fitlers are merged on top and will build a conjunction filter set.
        #
        # Due to the nature of +#find_by+ calls they act as query building
        # terminators, so we execute the actual search. While doing so we
        # respect the bang and non-bang variants. When non-bang variant is
        # called and no result was found we return +nil+. When the bang variant
        # was called we raise the +Hausgold::EntityNotFound+ error.
        #
        # @param args [Hash{Symbol => Mixed}] the additional filters to set
        # @return [Hausgold::BaseEntity, nil] the search result
        # @raise [Hausgold::EntityNotFound] when in bang-mode and
        #   nothing was found
        def find_by(**args)
          bang = args.fetch(:bang, false)

          raise! if bang
          limit(1).offset(0)
          where(args.except(:bang)) if args.any?

          result = first

          raise Hausgold::EntityNotFound.new(nil, entity_class, self) \
            if bang && result.nil?

          result
        end

        # Force the client driver to raise errors. This allows for lean
        # +Enumerable+ usage while providing the control of error handling.
        # By default all errors are swallowed to be +ActiveRecord+ compatible.
        #
        # @example A in-deep error
        #
        #   Hausgold::User.all.limit(10).raise! do |user|
        #     # do your user stuff
        #   end
        #   # => May raise errors while searching and paging
        #
        # @return [Hausgold::SearchCriteria] the current criteria instance
        def raise!
          criteria[:raise_errors] = true
          self
        end
      end
    end
    # rubocop:enable Metrics/BlockLength
  end
end
