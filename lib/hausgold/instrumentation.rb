# frozen_string_literal: true

module Hausgold
  # Some instrumentation and logging facility helpers.
  module Instrumentation
    extend ActiveSupport::Concern

    included do
      # Add the log subscriber to the faraday namespace
      Hausgold::Instrumentation::LogSubscriber.attach_to :faraday
    end

    class_methods do
      include Hausgold::Utils::Bangers

      # A generic root helper to generate dynamic test data.
      #
      # @param entity [String, Symbol] the entity to use for instrumentation
      # @param bang [Boolean] whenever to raise exceptions or not
      # @param traits [Array<String, Symbol>] the factory traits to use
      # @param overwrite [Hash{Symbol => Mixed}] overwrite properties
      # @return [Hausgold::BaseEntity, nil] the entity, or +nil+ on error
      def instrument(entity, *traits, bang: false, **overwrite)
        # When no instrumentation for the given entity was found, we raise
        raise ArgumentError, "No instrumentation for '#{entity}'" \
          unless entity_instrumentations.key? entity.to_sym

        # Perform the instrumentation action
        entity_instrumentations[entity].send(
          "instrument_#{entity}", *traits, bang: bang, **overwrite
        )
      end

      # Build and memoize an instrumentation client map for all entities.
      #
      # @return [Hash{Symbol => Hausgold::Client::Base}] the entity to
      #   client map
      def entity_instrumentations
        @entity_instrumentations ||= begin
          api_names(exclude_local_app: false)
            .map { |name| app(name) }.uniq
            .select { |client| client.respond_to? :factories_i13n }
            .flat_map do |client|
              keys = client.factories_i13n.keys
              keys.zip(keys.dup.fill(client))
            end.to_h
        end
      end

      # Generate bang method variants
      bangers :instrument
    end
  end
end
