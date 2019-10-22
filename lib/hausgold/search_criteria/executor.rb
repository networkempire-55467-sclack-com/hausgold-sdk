# frozen_string_literal: true

module Hausgold
  module Search
    # The search request executor.
    #
    # rubocop:disable Metrics/BlockLength because of ActiveSupport::Concern
    module Executor
      extend ActiveSupport::Concern

      included do
        include Hausgold::Utils::Bangers
        include Enumerable

        # Get back the page cursor which tracks the paging execution. The
        # cursor is an +Enumerator+ which reflects the planned pages range
        # (+#pages+). By doing so, subsequent calls will result in the very
        # same instance. (Memoization)
        #
        # @return [Enumerator] the page cursor
        def page_cursor
          @page_cursor ||= pages.to_enum.lazy
        end

        # Get back the current page we are on for the paging execution. This
        # can be consumed by low-level clients for a page parameter to signal
        # which page they request. (Based on the +#page_cursor+ method)
        #
        # @return [Integer] the current page on the cursor
        def current_page
          page_cursor.peek
        end

        # It the page cursor on the first page of the overall page range or
        # not. (Based on the +#page_cursor+ method)
        #
        # @return [Boolean] page cursor is on the first page, or not
        def first_page?
          current_page == pages.begin
        end

        # It the page cursor on the last page of the overall page range or not.
        # (Based on the +#page_cursor+ method) When there is an open end
        # defined as last page (Infinity) it always returns +false+.
        #
        # @return [Boolean] page cursor is on the last page, or not
        def last_page?
          current_page == pages.end
        end

        # Plan and execute the search and yield every found entity. This serves
        # the enumerable API and allows a lot of other methods like +take+,
        # +first+, +select+, etc.
        #
        # @param args [Hash{Symbol => Mixed}] additional request parameters
        # @yield [Hausgold::BaseEntity] a single found entity
        #
        # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity because
        #   that's the bare paging/execution
        # rubocop:disable Metrics/PerceivedComplexity because it looks hard,
        #   but it's straight forward to its core
        # rubocop:disable Metrics/MethodLength because its a bit too long but
        #   that's the optimized core
        def each(**args)
          client = entity_class.client_class.new
          method = \
            "search_#{entity_class.remote_entity_name.underscore.pluralize}"
          args = { bang: criteria[:raise_errors] }.merge(args)

          loop do
            begin
              # The search request driver MAY raise errors or pass back +nil+
              # on errors for silent processing. We need to handle this and
              # cast them to empty pages.
              page = client.send(method, self, args) || []
              transmission_count = page.count

              # Take care of the offset slicing when we are on the first page
              # and the page boundary is unaligned
              page = page.slice(relative_first_page_result_slice) || [] \
                if first_page? && first_page_unaligned?

              # Take care of the offset slicing when we are on the last page
              # and the page boundary is unaligned. This never affects
              # pages with an "unexpected" due to "missing" data, because
              # of the planned and the actual last page.
              page = page.slice(relative_last_page_result_slice) || [] \
                if last_page? && last_page_unaligned?

              # Serve the +Enumerable+ interface and yield each found entity
              page.each { |entity| yield(entity) }

              # We also stop paging when the page does not fill its boundaries,
              # because this indicates an "unexpected" end. The planned pages
              # MUST NOT be fully served by the API, when there is not enough
              # data to respond. This also includes completely empty pages.
              raise StopIteration if transmission_count < per_page

              # Fetch the next page on our cursor
              page_cursor.next
            rescue StopIteration
              break
            end
          end
        end
        # rubocop:enable Metrics/AbcSize, Metrics/CyclomaticComplexity
        # rubocop:enable Metrics/PerceivedComplexity
        # rubocop:enable Metrics/MethodLength

        bangers :each
      end
    end
    # rubocop:enable Metrics/BlockLength
  end
end
