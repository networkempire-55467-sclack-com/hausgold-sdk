# frozen_string_literal: true

module Hausgold
  module Search
    # The client request planer / paging algorithm.
    #
    # rubocop:disable Metrics/BlockLength because of ActiveSupport::Concern
    # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity because of
    #   the bare algorithm logic
    module Paging
      extend ActiveSupport::Concern

      included do
        # Calculate the a good page size for the search request(s). We take
        # care of the configured +max_per_page+ size to respect API server
        # load/rate limits.
        #
        # @return [Integer] the optimized page size
        def per_page
          @per_page ||= begin
            per_page = limit
            per_page = max_per_page if limit > max_per_page || limit.zero?
            per_page = offset + limit \
              if limit > 1 && offset != limit \
                && (offset + limit) <= max_per_page
            per_page
          end
        end

        # Return the page range for the search request(s). The range may be
        # open-ended or one-sized depending on the planned request paging
        # layout. The first page is always 1 or greater.
        #
        # @return [Range] the planned page range
        def pages
          @pages ||= first_page[:page]..last_page[:page]
        end

        # Returns +true+ when the first page is boundary aligned, so the full
        # page can be used without slicing.  Otherwise it returns +false+, so
        # slicing must be done.
        #
        # @return [Boolean] whenever the first page is aligned, or not
        def first_page_aligned?
          first_page[:start_offset].zero?
        end

        # Returns +true+ when the last page is boundary aligned, so the full
        # page can be used without slicing. Otherwise it returns +false+, so
        # slicing must be done.
        #
        # @return [Boolean] whenever the last page is aligned, or not
        def last_page_aligned?
          relative_last_page_result_slice.end == -1
        end

        # Just the opposite of +#first_page_aligned?+. May be used to write
        # more expressive code.
        #
        # @return [Boolean] whenever the first page is unaligned, or not
        def first_page_unaligned?
          !first_page_aligned?
        end

        # Just the opposite of +#last_page_aligned?+. May be used to write
        # more expressive code.
        #
        # @return [Boolean] whenever the last page is unaligned, or not
        def last_page_unaligned?
          !last_page_aligned?
        end

        # The paging layout may require slicing of the result fragment over all
        # page results. This comes from unaligned pages which may occur at the
        # begin of the first page or end of the last page. Page alignment is
        # not always possible or desired. Bigger page sizes result in less
        # requests which is the top priority.
        #
        # The result slice is an absolute range over the full result set.
        #
        # @return [Range] the result slicing range
        def result_slice
          @result_slice ||= first_page[:start_offset]..last_page[:start_offset]
        end

        # The details from +#result_slice+ (absolute slicing) applies to
        # relative slicing, too. Relative slicing is not performed over the
        # full result set, instead it is applied only to the first and last
        # page with respect of the paging layout. The relative slicing is
        # useful for stream processing.
        #
        # @return [Range] the first page relative slicing range
        def relative_first_page_result_slice
          first_page[:start_offset]..-1
        end

        # Just like the +#relative_first_page_result_slice+, but for the last
        # page. The relative slicing is useful for stream processing.
        #
        # @return [Range] the first page relative slicing range
        def relative_last_page_result_slice
          # When the total is infinity, the ending is infinity, too
          return 0..-1 if last_page[:total] == Float::INFINITY

          # Take (n) from total elements
          take = first_page[:skipped] + first_page[:start_offset] + limit

          # Drop the zero-indexing offset (2) for the slice range, and when
          # result is (-1) we slice for one element, or (-2) we use all
          ending = last_page[:total] - take - 2

          # Handle the below zero offsets
          ending += 1 if ending.negative?

          0..ending
        end

        # Calculate the first page of the planned request(s). We build up a
        # paging layout like this:
        #
        #   # [P1][P2][P3][P4]
        #
        # Afterwards we decide which pages are relevant for the search
        # request(s). In case the starting/ending pages are unaligned, we add
        # backlog pages to their respective predecessor/successors to balance
        # the pages with our search criteria. The result may look like this:
        #
        #   # [P1] ([P2][P3]) [P4]
        #
        # For this case we calculate the result set slicing range to crop off
        # the undesired starting/ending elements from the first/last page.
        #
        # The details of the first page include the actual starting page number
        # (+:page+), the skipped/offsetted elements and therefore the
        # predecessor of the first element id (+skipped+) and the start of the
        # result set slicing range (+start_offset+).
        #
        # @return [Hash{Symbol => Integer}] the first page details
        #
        # rubocop:disable Metrics/MethodLength because this is the
        #   minimum implementation
        def first_page
          @first_page ||= begin
            stop = offset >= per_page ? offset : offset + per_page

            pages = per_page.step(by: per_page, to: stop).to_a

            skipped = pages.last
            skipped = 0 if offset < per_page

            start_offset = (skipped - offset).abs
            start_offset = 0 if skipped == offset

            page = pages.count
            page += 1 if (skipped.positive? && skipped == offset) \
              || (skipped == per_page)

            { page: page, skipped: skipped, start_offset: start_offset }
          end
        end
        # rubocop:enable Metrics/MethodLength

        # If no limits were set, the last page is unknown and therefore
        # +Float::INFINITY+. In case a limit is configured we calculate the
        # respective last page details. This take care of unaligned page
        # contents by calculating the respective result set slicing range end.
        #
        # The details of the last page include the actual ending page number
        # (+:page+), the total elements amout of the paging (+total+) and the
        # end of the result set slicing range (+start_offset+). It is named
        # start offset because it is relative to the first page slicing range
        # start.  The full slicing range reflects the limit settings.
        #
        # @return [Hash{Symbol => Integer}] the last page details
        #
        # rubocop:disable Metrics/MethodLength because this is the
        #   minimum implementation
        def last_page
          @last_page ||= begin
            page = total = Float::INFINITY
            start_offset = -1

            if limit.positive?
              pages = []
              total = offset + limit
              start_offset = first_page[:start_offset] + limit - 1

              start = first_page[:skipped] + per_page
              stop = first_page[:skipped] + first_page[:start_offset] + limit

              if start != stop
                pages = start.step(by: per_page, to: stop).to_a

                # When the last page is unaligned, we add a backlog page
                pages << (pages.last + per_page) if pages.last < total

                # We remove our starting page, when the first page offset fits
                # in the per page size, so this page is already the first page
                pages.shift if first_page[:start_offset] < per_page

                total = pages.last
              end

              page = pages.count + first_page[:page]
            end

            { page: page, total: total, start_offset: start_offset }
          end
        end
        # rubocop:enable Metrics/MethodLength
      end
    end
    # rubocop:enable Metrics/AbcSize, Metrics/CyclomaticComplexity
    # rubocop:enable Metrics/BlockLength
  end
end
