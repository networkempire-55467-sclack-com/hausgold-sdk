# frozen_string_literal: true

RSpec.describe Hausgold::Search::Paging do
  all = Float::INFINITY
  slice_inf = -1
  max_per_page = 250
  first_page = 1..1
  all_pages = 1..all
  first_slice = 0..0
  all_slices = 0..slice_inf

  [
    {
      desc: 'where only',
      criteria: criteria.where(text: '@'),
      paging: { pages: all_pages, per_page: max_per_page, slice: all_slices },
      relative_slicing: { first_page: all_slices, last_page: all_slices },
      alignment: { first: true, last: true },
      details: { skipped: 0, total: all }
    },
    {
      desc: 'limit only',
      criteria: criteria.limit(5),
      paging: { pages: first_page, per_page: 5, slice: 0..4 },
      relative_slicing: { first_page: all_slices, last_page: all_slices },
      alignment: { first: true, last: true },
      details: { skipped: 0, total: 5 }
    },
    {
      desc: 'offset only',
      criteria: criteria.offset(5),
      paging: { pages: all_pages, per_page: max_per_page, slice: 5..slice_inf },
      relative_slicing: { first_page: 5..slice_inf, last_page: all_slices },
      alignment: { first: false, last: true },
      details: { skipped: 0, total: all }
    },
    {
      desc: 'equal offset and limit',
      criteria: criteria.offset(5).limit(5),
      paging: { pages: 2..2, per_page: 5, slice: 0..4 },
      relative_slicing: { first_page: all_slices, last_page: all_slices },
      alignment: { first: true, last: true },
      details: { skipped: 5, total: 10 }
    },
    {
      desc: 'low offset and low limit',
      criteria: criteria.offset(12).limit(31),
      paging: { pages: first_page, per_page: 43, slice: 12..42 },
      relative_slicing: { first_page: 12..slice_inf, last_page: all_slices },
      alignment: { first: false, last: true },
      details: { skipped: 0, total: 43 }
    },
    {
      desc: 'low offset and high limit',
      criteria: criteria.offset(12).limit(1000),
      paging: { pages: 1..5, per_page: max_per_page, slice: 12..1011 },
      relative_slicing: { first_page: 12..slice_inf, last_page: 0..236 },
      alignment: { first: false, last: false },
      details: { skipped: 0, total: 1250 }
    },
    {
      desc: 'high offset and low limit',
      criteria: criteria.offset(2135).limit(5),
      paging: { pages: 428..428, per_page: 5, slice: 0..4 },
      relative_slicing: { first_page: all_slices, last_page: all_slices },
      alignment: { first: true, last: true },
      details: { skipped: 2135, total: 2140 }
    },
    {
      desc: 'high fractional dividable offset and low limit',
      criteria: criteria.offset(2134).limit(5),
      paging: { pages: 426..427, per_page: 5, slice: 4..8 },
      relative_slicing: { first_page: 4..slice_inf, last_page: first_slice },
      alignment: { first: false, last: false },
      details: { skipped: 2130, total: 2140 }
    },
    {
      desc: 'high prime offset and low limit',
      criteria: criteria.offset(2141).limit(5),
      paging: { pages: 428..429, per_page: 5, slice: 1..5 },
      relative_slicing: { first_page: 1..slice_inf, last_page: 0..2 },
      alignment: { first: false, last: false },
      details: { skipped: 2140, total: 2150 }
    },
    {
      desc: 'low offset and fractional dividable limit',
      criteria: criteria.offset(5).limit(2134),
      paging: { pages: 1..9, per_page: max_per_page, slice: 5..2138 },
      relative_slicing: { first_page: 5..slice_inf, last_page: 0..109 },
      alignment: { first: false, last: false },
      details: { skipped: 0, total: 2250 }
    },
    {
      desc: 'low offset and prime limit',
      criteria: criteria.offset(5).limit(2141),
      paging: { pages: 1..9, per_page: max_per_page, slice: 5..2145 },
      relative_slicing: { first_page: 5..slice_inf, last_page: 0..102 },
      alignment: { first: false, last: false },
      details: { skipped: 0, total: 2250 }
    },
    {
      desc: 'equal prime offset and limit',
      criteria: criteria.offset(2141).limit(2141),
      paging: { pages: 8..17, per_page: max_per_page, slice: 141..2281 },
      relative_slicing: { first_page: 141..slice_inf, last_page: 0..216 },
      alignment: { first: false, last: false },
      details: { skipped: 2000, total: 4500 }
    },
    {
      desc: 'high offset and high limit',
      criteria: criteria.offset(212).limit(1454),
      paging: { pages: 1..7, per_page: max_per_page, slice: 212..1665 },
      relative_slicing: { first_page: 212..slice_inf, last_page: 0..82 },
      alignment: { first: false, last: false },
      details: { skipped: 0, total: 1750 }
    },
    {
      desc: 'high offset and limit 1',
      criteria: criteria.offset(2141).limit(1),
      paging: { pages: 2142..2142, per_page: 1, slice: first_slice },
      relative_slicing: { first_page: all_slices, last_page: all_slices },
      alignment: { first: true, last: true },
      details: { skipped: 2141, total: 2142 }
    },
    {
      desc: 'medium offset and limit 1',
      criteria: criteria.offset(22).limit(1),
      paging: { pages: 23..23, per_page: 1, slice: first_slice },
      relative_slicing: { first_page: all_slices, last_page: all_slices },
      alignment: { first: true, last: true },
      details: { skipped: 22, total: 23 }
    },
    {
      desc: 'offset and limit 1',
      criteria: criteria.offset(1).limit(1),
      paging: { pages: 2..2, per_page: 1, slice: first_slice },
      relative_slicing: { first_page: all_slices, last_page: all_slices },
      alignment: { first: true, last: true },
      details: { skipped: 1, total: 2 }
    },
    {
      desc: 'limit and changed max per page (aligned)',
      criteria: criteria(max_per_page: 2).limit(10),
      paging: { pages: 1..5, per_page: 2, slice: 0..9 },
      relative_slicing: { first_page: all_slices, last_page: all_slices },
      alignment: { first: true, last: true },
      details: { skipped: 0, total: 10 }
    },
    {
      desc: 'limit and changed max per page (unaligned)',
      criteria: criteria(max_per_page: 2).limit(11),
      paging: { pages: 1..6, per_page: 2, slice: 0..10 },
      relative_slicing: { first_page: all_slices, last_page: first_slice },
      alignment: { first: true, last: false },
      details: { skipped: 0, total: 12 }
    },
    {
      desc: 'offset, limit and changed max per page (aligned)',
      criteria: criteria(max_per_page: 3).offset(3).limit(9),
      paging: { pages: 2..4, per_page: 3, slice: 0..8 },
      relative_slicing: { first_page: all_slices, last_page: all_slices },
      alignment: { first: true, last: true },
      details: { skipped: 3, total: 12 }
    },
    {
      desc: 'offset, limit and changed max per page (unaligned)',
      criteria: criteria(max_per_page: 3).offset(4).limit(11),
      paging: { pages: 2..5, per_page: 3, slice: 1..11 },
      relative_slicing: { first_page: 1..slice_inf, last_page: all_slices },
      alignment: { first: false, last: true },
      details: { skipped: 3, total: 15 }
    },
    {
      desc: 'high offset, limit and changed max per page (unaligned)',
      criteria: criteria(max_per_page: 7).offset(895).limit(44),
      paging: { pages: 127..134, per_page: 7, slice: 6..49 },
      relative_slicing: { first_page: 6..slice_inf, last_page: 0..4 },
      alignment: { first: false, last: false },
      details: { skipped: 889, total: 945 }
    }
  ].each do |test|
    context "with #{test[:desc]}" do
      criteria = test[:criteria]
      first_page_align, last_page_align = test[:alignment].values
      skipped, total = test[:details].values
      pages, per_page, slice = test[:paging].values
      first_page_slice, last_page_slice = test[:relative_slicing].values

      describe 'pages' do
        it "plans the per page size (#{per_page}) correctly" do
          expect(criteria.per_page).to be_eql(per_page)
        end

        it "plans the first page (#{pages.begin}) correctly" do
          expect(criteria.first_page[:page]).to be_eql(pages.begin)
        end

        it "plans the last page (#{pages.end}) correctly" do
          expect(criteria.last_page[:page]).to be_eql(pages.end)
        end

        it "plans the pages range (#{pages}) correctly" do
          expect(criteria.pages).to be_eql(pages)
        end
      end

      describe 'page alignments' do
        if first_page_align
          it 'detects the first page is aligned' do
            expect(criteria.first_page_aligned?).to be(true)
          end
        else
          it 'detects the first page is unaligned' do
            expect(criteria.first_page_unaligned?).to be(true)
          end
        end

        if last_page_align
          it 'detects the last page is aligned' do
            expect(criteria.last_page_aligned?).to be(true)
          end
        else
          it 'detects the last page is unaligned' do
            expect(criteria.last_page_unaligned?).to be(true)
          end
        end
      end

      describe 'absolute result slicing' do
        it "plans the slice begin (#{slice.begin}) correctly" do
          expect(criteria.first_page[:start_offset]).to be_eql(slice.begin)
        end

        it "plans the slice end (#{slice.end}) correctly" do
          expect(criteria.last_page[:start_offset]).to be_eql(slice.end)
        end

        it "plans the result slice (#{slice}) correctly" do
          expect(criteria.result_slice).to be_eql(slice)
        end

        unless slice.end == slice_inf
          it "plans the result slice to match the limit (#{criteria.limit})" do
            expect(criteria.result_slice.to_a.size).to \
              be_eql(criteria.limit)
          end
        end
      end

      describe 'relative result slicing' do
        it "plans the first page slice (#{first_page_slice}) correctly" do
          expect(criteria.relative_first_page_result_slice).to \
            be_eql(first_page_slice)
        end

        it "plans the last page slice (#{last_page_slice}) correctly" do
          expect(criteria.relative_last_page_result_slice).to \
            be_eql(last_page_slice)
        end
      end

      describe 'paging elements' do
        it "calculates the skipped elements correctly (#{skipped})" do
          expect(criteria.first_page[:skipped]).to be_eql(skipped)
        end

        it "calculates the total elements correctly (#{total})" do
          expect(criteria.last_page[:total]).to be_eql(total)
        end
      end
    end
  end
end
