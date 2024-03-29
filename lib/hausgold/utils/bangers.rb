# frozen_string_literal: true

module Hausgold
  module Utils
    # Generate bang variants of methods which use the +Decision+ flow control.
    module Bangers
      extend ActiveSupport::Concern

      class_methods do
        # Generate bang variants for the given methods.
        # Be sure to use the +bangers+ class method AFTER all method
        # definitions, otherwise it will raise errors about missing methods.
        #
        # @param methods [Array<Symbol>] the source method names
        # @raise [NoMethodError] when a source method is not defined
        # @raise [ArgumentError] when a source method does not accept arguments
        #
        # rubocop:disable Metrics/MethodLength because the method template
        #   is better inlined
        def bangers(*methods)
          methods.each do |meth|
            raise NoMethodError, "#{self}##{meth} does not exit" \
              unless instance_methods(false).include? meth

            raise ArgumentError, "#{self}##{meth} does not accept arguments" \
              if instance_method(meth).arity.zero?

            class_eval <<-RUBY, __FILE__, __LINE__ + 1
              def #{meth}!(*args)
                if args.last.is_a? Hash
                  args.last.merge!(bang: true)
                else
                  args.push({ bang: true })
                end
                #{meth}(*args)
              end
            RUBY
          end
        end
        # rubocop:enable Metrics/MethodLength
      end
    end
  end
end
