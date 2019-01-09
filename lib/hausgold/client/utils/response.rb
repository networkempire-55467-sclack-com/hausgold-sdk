# frozen_string_literal: true

module Hausgold
  module ClientUtils
    # Some helpers to work with responses in a general way.
    #
    # rubocop:disable Metrics/BlockLength because of ActiveSupport::Concern
    module Response
      extend ActiveSupport::Concern

      included do
        # Simple helper to query the response status.
        #
        # @param res [Faraday::response] the response object
        # @param code [Range, Array, Integer] the range of good response codes
        # @return [Boolean] whenever the request got an allowed status
        def status?(res, code: 0..399)
          code = [code] unless code.is_a? Range
          code = code.flatten if code.is_a? Array
          code.include? res.status
        end
        alias_method :successful?, :status?

        # A simple syntactic sugar helper to query the response status.
        #
        # @param res [Faraday::response] the response object
        # @param code [Range] the range of failed response codes
        # @return [Boolean] whenever the request failed
        def failed?(res, code: 400..600)
          status?(res, code: code)
        end

        # A common error handling mechanic. It checks the given response for
        # common errors, such like 404 and stuff like that and raises
        # accordingly.
        #
        # @param res [Faraday::Response] the response to check
        # @return [Faraday::Response] pass back the response, for chaining
        # @raise [Hausgold::EntityNotFound] when status is 404
        def raise_on_errors(res)
          # The requested entity was not found
          raise Hausgold::EntityNotFound if res.status == 404
          # An error occured, but it's not handled in a specific way
          raise Hausgold::RequestError.new(nil, res) \
            if failed?(res, code: 400..600)

          # Everything went well, pass the response back
          res
        end

        # Perform a common error handling for entity responses. This allows a
        # clean usage of the decision flow control. Here comes an example:
        #
        #   decision do |result|
        #     result.bang(&bang_entity(entity, res, id: entity.id))
        #   end
        #
        # @param entity [Hausgold::BaseEntity, Class] the result entity
        # @param res [Faraday::Response] the response object
        # @param criteria [Hash{Symbol => Mixed}] the identifier criteria
        # @return [Proc] the proc which performs the error handling
        def bang_entity(entity, res, **criteria)
          class_name = entity
          class_name = entity.class unless entity.is_a? Class
          lambda do
            next Hausgold::EntityNotFound.new(nil, class_name, **criteria) \
              if res.status == 404
            next Hausgold::EntityInvalid.new(res.body.message) \
              if res.body.code == 3

            Hausgold::RequestError.new(nil, res)
          end
        end

        # Perform the assignment of the response to the given entity. This
        # allows a clean usage of the decision flow control for successful
        # requests. Here comes an example:
        #
        #   decision do |result|
        #     result.good(&assign_entity(entity, res))
        #   end
        #
        # @return [Proc] the proc which performs the error handling
        def assign_entity(entity, res, &block)
          lambda do
            entity.assign_attributes(res.body.to_h)
            entity.changes_applied
            # We need to call +#changed?+ - the +@mutations_from_database+ is
            # unset and this causes issues on subsequent calls to +#changed?+
            # after a freeze (eg. when deleted)
            entity.changed?
            yield(entity) if block
            entity
          end
        end

        # Fake a Faraday response 404 not found response. This can be helpful
        # for client level validations which inspect the URL paths. When a
        # request will result into a not found response, because some required
        # path tokens are missing, it makes no sense to razz the application.
        #
        # @return [Faraday::Response] the not found response
        def not_found
          con = connection
          env = con.builder.build_env(con, con.build_request(:options))
          env.status = 404
          env.reason_phrase = 'Not found'
          res = Faraday::Response.new
          env.response = res
          res.finish(env)
        end
      end
    end
    # rubocop:enable Metrics/BlockLength
  end
end
