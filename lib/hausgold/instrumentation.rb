# frozen_string_literal: true

module Hausgold
  # Some instrumentation and logging facility helpers.
  module Instrumentation
    extend ActiveSupport::Concern

    included do
      # Listen to requests
      ActiveSupport::Notifications.subscribe('request.faraday') \
        do |_name, started_at, ended_at, _, env|
        # Don't waste time when we're not configured to log
        next unless Hausgold.configuration.request_logging

        # Print some top-level request/action details
        Hausgold.logger.info do
          "[#{req_id(env)}] #{req_origin(env)} -> #{res_result(env)} " \
            "#{req_duration(started_at, ended_at)}"
        end

        # Print details about the request
        Hausgold.logger.debug do
          "[#{req_id(env)}] > #{req_dest(env)} " \
            "#{env.request_headers.sort.to_h.to_json}"
        end

        # Print details about the response
        Hausgold.logger.debug do
          "[#{req_id(env)}] < " \
            "#{env.response_headers.sort.to_h.to_json}"
        end
      end
    end

    class_methods do
      private

      # Format the request identifier.
      #
      # @param env [Faraday::Env] the request/response environment
      # @return [String] the request identifier
      def req_id(env)
        env.request.context[:request_id].to_s
      end

      # Format the request/action origin.
      #
      # @param env [Faraday::Env] the request/response environment
      # @return [String] the request identifier
      def req_origin(env)
        req = env.request.context
        "#{Hausgold.env}/#{req[:client]}##{req[:action]}"
      end

      # Format the request destination.
      #
      # @param env [Faraday::Env] the request/response environment
      # @return [String] the request identifier
      def req_dest(env)
        "#{env[:method].to_s.upcase} #{env[:url]}"
      end

      # Format the request result.
      #
      # @param env [Faraday::Env] the request/response environment
      # @return [String] the request identifier
      def res_result(env)
        format("#{env[:status]}/#{env[:reason_phrase]}")
      end

      # Format the request duration.
      #
      # @param started_at [Integer] the timestamp when the request was started
      # @param ended_at [Integer] the timestamp when the request was finished
      # @return [String] the formatted request duration
      def req_duration(started_at, ended_at)
        format('(%.1fms)', (ended_at - started_at) * 1000)
      end
    end
  end
end
