# frozen_string_literal: true

module Hausgold
  module IdentityApi
    # All the user relevant actions.
    module Users
      extend ActiveSupport::Concern

      included do
        %i[confirm lock recover recovered unconfirm unlock].each do |kind|
          class_eval <<-RUBY, __FILE__, __LINE__ + 1
            # #{kind.to_s.titleize} a single user.
            #
            # @param user [Hausgold::User] the user instance to use
            # @param args [Hash{Symbol => Mixed}] additional request params
            # @return [Hausgold::User] the given entity, but reloaded
            def #{kind}_user(user, **args)
              user_workflow(:#{kind}, user, **args)
            end

            # Generate bang method variants
            bangers :#{kind}_user
          RUBY
        end

        # Perform a regular user workflow request. It does not matter if you
        # are starting a new workflow, or complete a running one because the
        # API is barely the same. We peform the actual request with the given
        # parameters to the workflow API and reload the given instance
        # afterwards to reflect entity changes.
        #
        # @param workflow [String, Symbol] the name of the workflow to use
        # @param user [Hausgold::User] the user instance to use
        # @param args [Hash{Symbol => Mixed}] additional request params
        # @return [Hausgold::User] the given entity, but reloaded
        #
        # rubocop:disable Metrics/MethodLength because thats the bare minimum
        def user_workflow(workflow, user, **args)
          identifier = user.identifier
          res = connection.post do |req|
            req.path = "/v1/users/workflows/#{workflow}"
            req.body = identifier.merge(args)
            use_default_context(req)
            use_jwt(req)
          end
          decision(bang: args.fetch(:bang, false)) do |result|
            result.bang(&bang_entity(user, res, identifier))
            result.good(&assign_entity(user, res))
            successful?(res)
          end
        end
        # rubocop:enable Metrics/MethodLength
      end
    end
  end
end
