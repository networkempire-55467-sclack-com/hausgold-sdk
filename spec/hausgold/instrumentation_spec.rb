# frozen_string_literal: true

RSpec.describe Hausgold::Instrumentation do
  let(:described_class) { Hausgold }

  describe '.instrument' do
    context 'with unknown instrumentation entity' do
      it 'raises an ArgumentError' do
        expect { described_class.instrument(:unknown) }.to \
          raise_error(ArgumentError, /unknown/)
      end
    end

    context 'with known instrumentation entity' do
      it 'uses the correct client and action' do
        expect(described_class.entity_instrumentations[:broker]).to \
          receive(:instrument_broker).once
        described_class.instrument(:broker)
      end

      it 'passes all factory arguments' do
        args = [:trait_a, :trait_b, test_a: { a: true }, bang: false]
        expect(described_class.entity_instrumentations[:broker]).to \
          receive(:instrument_broker).once.with(*args)
        described_class.instrument(:broker, *args)
      end
    end
  end

  describe '.instrument!' do
    it 'passes the bang argument' do
      expect(described_class.entity_instrumentations[:broker]).to \
        receive(:instrument_broker).once.with(bang: true)
      described_class.instrument!(:broker)
    end
  end

  describe '.entity_instrumentations' do
    it 'returns a hash' do
      expect(described_class.entity_instrumentations).to be_a(Hash)
    end

    it 'returns client instances as values' do
      expect(described_class.entity_instrumentations.values).to \
        all(be_a(Hausgold::Client::Base))
    end

    it 'memoizes the result' do
      expect(described_class.entity_instrumentations).to \
        be(described_class.entity_instrumentations)
    end
  end
end
