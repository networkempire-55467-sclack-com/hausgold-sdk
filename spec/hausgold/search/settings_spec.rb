# frozen_string_literal: true

RSpec.describe Hausgold::Search::Settings do
  describe '#criteria' do
    it 'return a hash' do
      expect(criteria.criteria).to be_a(Hash)
    end

    it 'returns the default settings' do
      expect(criteria.criteria).to \
        match(filters: {}, limit: 0, offset: 0, raise_errors: false)
    end

    it 'returns changed settings' do
      instance = criteria.tap { |obj| obj.limit(123) }
      expect(instance.criteria).to \
        match(filters: {}, limit: 123, offset: 0, raise_errors: false)
    end
  end

  describe '#all' do
    it 'returns itself' do
      instance = criteria
      expect(instance.all).to be(instance)
    end

    it 'resets to default filters' do
      instance = criteria.tap { |obj| obj.where(test: true) }
      expect(instance.all.criteria[:filters]).to be_eql({})
    end

    it 'resets to default limit' do
      instance = criteria.tap { |obj| obj.limit(123) }
      expect(instance.all.criteria[:limit]).to be(0)
    end

    it 'resets to default offset' do
      instance = criteria.tap { |obj| obj.offset(123) }
      expect(instance.all.criteria[:offset]).to be(0)
    end

    it 'resets to default raise_errors' do
      instance = criteria.tap(&:raise!)
      expect(instance.all.criteria[:raise_errors]).to be(false)
    end
  end

  describe '#limit' do
    context 'with count' do
      it 'returns itself' do
        instance = criteria
        expect(instance.limit(123)).to be(instance)
      end

      it 'sets the new count' do
        instance = criteria
        expect(instance.limit(123).criteria).to include(limit: 123)
      end
    end

    context 'without count' do
      it 'returns the limit' do
        instance = criteria
        expect(instance.limit).to be(0)
      end
    end
  end

  describe '#offset' do
    context 'with count' do
      it 'returns itself' do
        instance = criteria
        expect(instance.offset(123)).to be(instance)
      end

      it 'sets the new count' do
        instance = criteria
        expect(instance.offset(123).criteria).to include(offset: 123)
      end
    end

    context 'without count' do
      it 'returns the offset' do
        instance = criteria
        expect(instance.offset).to be(0)
      end
    end
  end

  describe '#where' do
    context 'with filters' do
      it 'returns itself' do
        instance = criteria
        expect(instance.where(test: true)).to be(instance)
      end

      it 'merges the new filters' do
        instance = criteria.where(test: true)
        expect(instance.where(test: false).criteria).to \
          include(filters: { test: false })
      end
    end

    context 'without new fitlers' do
      it 'returns the filters' do
        instance = criteria
        expect(instance.where).to be_eql({})
      end
    end
  end

  describe '#find_by' do
    let(:filters) { {} }
    let(:instance) do
      criteria.tap do |obj|
        obj.limit(123).offset(123).where(other: true)
      end
    end
    let(:action) { instance.find_by(**filters) }

    before do
      allow(instance).to receive(:each).and_return([])
    end

    context 'with filters' do
      let(:filters) { { test: true } }

      before { action }

      it 'merges the filters' do
        expect(instance.where).to match(other: true, test: true)
      end

      it 'sets the limit to 1' do
        expect(instance.limit).to be(1)
      end

      it 'sets the offset to 0' do
        expect(instance.offset).to be(0)
      end
    end

    context 'without filters' do
      before { action }

      it 'merges no filters' do
        expect(instance.where).to match(other: true)
      end

      it 'sets the limit to 1' do
        expect(instance.limit).to be(1)
      end

      it 'sets the offset to 0' do
        expect(instance.offset).to be(0)
      end
    end
  end

  describe '#raise!' do
    let(:instance) do
      criteria.tap do |obj|
        obj.limit(123).offset(123).where(other: true)
      end
    end
    let(:action) { instance.raise! }

    it 'returns itself' do
      expect(action).to be(instance)
    end

    it 'sets the raise errors flag' do
      action
      expect(action.criteria).to include(raise_errors: true)
    end
  end
end
