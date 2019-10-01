# frozen_string_literal: true

module Hausgold
  module VerkaeuferportalApi
    # All the user relevant actions.
    module Users
      extend ActiveSupport::Concern

      included do
        %i[property_created].each do |kind|
          class_eval <<-RUBY, __FILE__, __LINE__ + 1
            # Notify a user about a #{kind.to_s.titleize} event.
            #
            # @param user [Hausgold::Customer] the user instance to use
            # @param args [Hash{Symbol => Mixed}] additional request params
            # @return [Hausgold::User] the given entity, but reloaded
            def user_notify_#{kind}(user, **args)
              user_notification(:#{kind}, user, **args)
            end

            # Generate bang method variants
            bangers :user_notify_#{kind}
          RUBY
        end

        # Perform a single user/notification request.
        #
        # @param event [String, Symbol] the name of the notification to use
        # @param user [Hausgold::User] the user instance to use
        # @param args [Hash{Symbol => Mixed}] additional request params
        # @return [Hausgold::User] the given entity, but reloaded
        #
        # rubocop:disable Metrics/MethodLength because thats the bare minimum
        # rubocop:disable Metrics/AbcSize because the decission
        #  handling is quite complex
        def user_notification(event, user, **args)
          parameters = args.except(:bang, :good)
          res = connection.post do |req|
            req.path = "/v1/users/#{user.id}/notifications/#{event}"
            req.body = parameters
            use_default_context(req)
            use_jwt(req)
          end
          decision(bang: args.fetch(:bang, false)) do |result|
            result.bang(&bang_entity(user, res, parameters))
            result.good do
              next(args[:good].call(user, res)) if args.key? :good

              assign_entity(user, res).call
            end
            successful?(res)
          end
        end
        # rubocop:enable Metrics/MethodLength
        # rubocop:enable Metrics/AbcSize
      end
    end
  end
end
