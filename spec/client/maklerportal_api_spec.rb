# frozen_string_literal: true

RSpec.describe Hausgold::Client::MaklerportalApi do
  let(:instance) { described_class.new }

  describe 'settings' do
    it 'registers instrumentation entities' do
      expect(described_class.factories_i13n.keys).to include(:broker)
    end
  end

  describe '.instrument_broker' do
    let(:params) { [] }
    let(:action) { instance.instrument_broker(*params) }

    context 'with all defaults' do
      it 'returns a Hausgold::Broker instance' do
        expect(action).to be_a(Hausgold::Broker)
      end

      it 'returns the correct instance' do
        expect(action.id).to be_eql('a1a2ef9e-cb85-4aa6-9cf4-0fc732c961a2')
      end
    end

    context 'with complex settings' do
      let(:email) { 'sdk-test@example.com' }
      let(:params) do
        [:confirmed, :with_avatar, :with_lead,
         lead_traits: %i[active realty_type], email: email]
      end

      it 'returns the correct instance' do
        expect(action.email).to be_eql(email)
      end
    end
  end

  describe '.instrument_broker!' do
    let(:params) { [] }
    let(:action) { instance.instrument_broker!(*params) }

    context 'with unknown trait' do
      let(:params) { [:unknown] }

      it 'raises an Hausgold::RequestError' do
        expect { action }.to raise_error(Hausgold::RequestError,
                                         /Trait not registered: unknown/)
      end
    end
  end
end
