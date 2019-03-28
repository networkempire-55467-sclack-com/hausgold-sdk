# frozen_string_literal: true

RSpec.describe Hausgold::Search::Executor do
  let(:instance) { criteria.offset(243).limit(2342) }

  describe '#page_cursor' do
    it 'returns a Enumerator' do
      expect(instance.page_cursor).to be_a(Enumerator)
    end

    it 'maps to the planned pages' do
      expect(instance.page_cursor.to_a).to be_eql(instance.pages.to_a)
    end

    it 'returns always the same instance' do
      expect(instance.page_cursor).to be(instance.page_cursor)
    end

    it 'allows position increment' do
      instance.page_cursor.next
      expect(instance.page_cursor.next).to be(2)
    end
  end

  describe '#current_page' do
    it 'gives the current page position' do
      expect(instance.current_page).to be(1)
    end

    it 'respects position increments' do
      instance.page_cursor.next
      expect(instance.current_page).to be(2)
    end

    it 'respects multiple position increments' do
      instance.page_cursor.next
      instance.page_cursor.next
      instance.page_cursor.next
      expect(instance.current_page).to be(4)
    end

    context 'with high offsets' do
      let(:instance) { criteria.offset(21_414).limit(500) }

      it 'starts with page 85' do
        expect(instance.current_page).to be(85)
      end

      it 'respects position increments' do
        instance.page_cursor.next
        expect(instance.current_page).to be(86)
      end

      it 'respects multiple position increments' do
        instance.page_cursor.next
        instance.page_cursor.next
        expect(instance.current_page).to be(87)
      end
    end
  end

  describe '#first_page?' do
    it 'detects the page cursor is on the first page' do
      expect(instance.first_page?).to be(true)
    end

    it 'detects the page cursor is not on the first page' do
      instance.page_cursor.next
      expect(instance.first_page?).to be(false)
    end
  end

  describe '#last_page?' do
    let(:instance) { criteria.limit(251) }

    it 'detects the page cursor is on the last page' do
      instance.page_cursor.next
      expect(instance.last_page?).to be(true)
    end

    it 'detects the page cursor is not on the last page' do
      expect(instance.last_page?).to be(false)
    end

    context 'without limit' do
      let(:instance) { criteria }

      it 'detects never the last page' do
        instance.page_cursor.next
        instance.page_cursor.next
        instance.page_cursor.next
        expect(instance.last_page?).to be(false)
      end
    end
  end

  describe '#each!' do
    it 'raises on search errors' do
      expect { criteria(entity: Hausgold::Task).each! }.to \
        raise_error(Hausgold::EntitySearchError,
                    /because: user_id, reference_ids are missing/)
    end
  end

  describe '#each' do
    let(:filters) do
      {
        user_id: '96092fa8-707d-4fe6-af5e-4898b9d87a90',
        text: 'Ehrenberg',
        from: Time.current.midnight.iso8601,
        to: 1.month.from_now.midnight.iso8601
      }
    end
    let(:action) do
      # We search for Calendar API development seeds which got a
      # sequential title (eg. +Task #3+)
      instance.map(&:title).map { |title| title.split('#').last.to_i }
    end

    before { Timecop.freeze(Time.utc(2019, 3, 25)) }

    after { Timecop.return }

    context 'with limit (max per page fit)' do
      let(:instance) do
        criteria(entity: Hausgold::Task, max_per_page: 3)
          .where(filters).limit(3)
      end

      it 'returns correct tasks' do
        expect(action).to be_eql((1..3).to_a)
      end
    end

    context 'with limit (max per page no-fit)' do
      let(:instance) do
        criteria(entity: Hausgold::Task, max_per_page: 3)
          .where(filters).limit(6)
      end

      it 'returns correct tasks' do
        expect(action).to be_eql((1..6).to_a)
      end
    end

    context 'with limit and offset (full aligned)' do
      let(:instance) do
        criteria(entity: Hausgold::Task, max_per_page: 3)
          .where(filters).offset(3).limit(3)
      end

      it 'has an aligned first page' do
        expect(instance.first_page_aligned?).to be(true)
      end

      it 'has an aligned last page' do
        expect(instance.last_page_aligned?).to be(true)
      end

      it 'returns correct tasks' do
        expect(action).to be_eql((4..6).to_a)
      end
    end

    context 'with limit and offset (first aligned, last unaligned)' do
      let(:instance) do
        criteria(entity: Hausgold::Task, max_per_page: 3)
          .where(filters).offset(3).limit(4)
      end

      it 'has an aligned first page' do
        expect(instance.first_page_aligned?).to be(true)
      end

      it 'has an unaligned last page' do
        expect(instance.last_page_unaligned?).to be(true)
      end

      it 'returns correct tasks' do
        expect(action).to be_eql((4..7).to_a)
      end
    end

    context 'with limit and offset (first unaligned, last aligned)' do
      let(:instance) do
        criteria(entity: Hausgold::Task, max_per_page: 3)
          .where(filters).offset(2).limit(4)
      end

      it 'has an unaligned first page' do
        expect(instance.first_page_unaligned?).to be(true)
      end

      it 'has an aligned last page' do
        expect(instance.last_page_aligned?).to be(true)
      end

      it 'returns correct tasks' do
        expect(action).to be_eql((3..6).to_a)
      end
    end

    context 'with offset and limit (full unaligned)' do
      let(:instance) do
        criteria(entity: Hausgold::Task, max_per_page: 3)
          .where(filters).offset(4).limit(12)
      end

      it 'has an unaligned first page' do
        expect(instance.first_page_unaligned?).to be(true)
      end

      it 'has an unaligned last page' do
        expect(instance.last_page_unaligned?).to be(true)
      end

      it 'returns correct tasks' do
        expect(action).to be_eql((5..16).to_a)
      end
    end

    context 'with offset and limit, and max per page (first unaligned)' do
      let(:instance) do
        criteria(entity: Hausgold::Task, max_per_page: 250)
          .where(filters).offset(4).limit(12)
      end

      it 'has an unaligned first page' do
        expect(instance.first_page_unaligned?).to be(true)
      end

      it 'has an aligned last page' do
        expect(instance.last_page_aligned?).to be(true)
      end

      it 'returns correct tasks' do
        expect(action).to be_eql((5..16).to_a)
      end
    end

    context 'with offset and limit 1' do
      let(:instance) do
        criteria(entity: Hausgold::Task, max_per_page: 250)
          .where(filters).offset(1).limit(1)
      end

      it 'returns correct tasks' do
        expect(action).to be_eql([2])
      end
    end

    context 'without limit and offset' do
      let(:instance) do
        criteria(entity: Hausgold::Task, max_per_page: 250)
          .where(filters.except(:text))
      end

      it 'returns correct tasks' do
        expect(action).to be_eql((0..20).to_a)
      end
    end

    context 'with high offset, no expected results' do
      let(:instance) do
        criteria(entity: Hausgold::Task, max_per_page: 250)
          .where(filters).offset(1000).limit(1)
      end

      it 'returns correct tasks' do
        expect(action).to be_eql([])
      end
    end

    context 'with chained raise!' do
      let(:instance) { criteria(entity: Hausgold::Task).raise! }

      it 'raises on search errors' do
        expect { action }.to \
          raise_error(Hausgold::EntitySearchError,
                      /because: user_id, reference_ids are missing/)
      end
    end
  end
end
