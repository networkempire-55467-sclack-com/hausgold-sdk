# frozen_string_literal: true

module Hausgold
  module Utils
    # A set of common matchers for all kind of data.
    module Matchers
      # An UUID matching regex, without start-end concerns
      UUID_PART = /\h{32}|\h{8}-\h{4}-\h{4}-\h{4}-\h{12}/.freeze
      # A general purpose UUID matching regex
      UUID = /\A(#{UUID_PART})\z/.freeze
      # A Global Id matching regex
      GID = %r{\A(gid://[a-zA-Z0-9-]+/\w+/#{UUID_PART})\z}.freeze

      class << self
        # Check if the given string is a Global Id.
        #
        # @param str [String] the string to check
        # @return [Boolean] whenever the string is a Global Id
        #
        # rubocop:disable Style/CaseEquality because of Ruby 2.3 compatibility
        def gid?(str)
          GID === str.to_s
        end
        # rubocop:enable Style/CaseEquality

        # Check if the given string is a UUID.
        #
        # @param str [String] the string to check
        # @return [Boolean] whenever the string is a UUID
        #
        # rubocop:disable Style/CaseEquality because of Ruby 2.3 compatibility
        def uuid?(str)
          UUID === str.to_s
        end
        # rubocop:enable Style/CaseEquality

        # Check if the given string is an email address.
        #
        # @param str [String] the string to check
        # @return [Boolean] whenever the string is an email address
        def email?(str)
          # Yeah its stupid, but its enough for now
          # @TODO: Maybe ruby-regex gem
          str.to_s.include? '@'
        end

        # Returns the first found UUID from the given string, otherwise +nil+.
        #
        # @param str [String] the string to scan
        # @return [String, nil] the found UUID or +nil+
        def uuid(str)
          str.to_s.scan(UUID_PART).first
        end
      end
    end
  end
end
