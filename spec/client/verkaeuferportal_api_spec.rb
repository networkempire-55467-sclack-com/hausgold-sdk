# frozen_string_literal: true

RSpec.describe Hausgold::Client::VerkaeuferportalApi do
  let(:instance) { described_class.new }

  describe 'settings' do
    it 'registers instrumentation entities' do
      expect(described_class.factories_i13n.keys).to include(:customer)
    end
  end

  describe '.instrument_customer' do
    let(:params) { [] }
    let(:action) { instance.instrument_customer(*params) }

    context 'with all defaults' do
      it 'returns a Hausgold::Customer instance' do
        expect(action).to be_a(Hausgold::Customer)
      end

      it 'returns the correct instance' do
        expect(action.id).to be_eql('511e824c-4e39-4354-ae60-81e175d1b1f4')
      end
    end

    context 'with complex settings' do
      let(:email) { 'sdk-test@example.com' }
      let(:params) do
        [:with_identity, :with_address, :with_property,
         property_type: :site, email: email]
      end

      it 'returns the correct instance' do
        expect(action.email).to be_eql(email)
      end
    end
  end

  describe '.instrument_customer!' do
    let(:params) { [] }
    let(:action) { instance.instrument_customer!(*params) }

    context 'with unknown trait' do
      let(:params) { [:unknown] }

      it 'raises an Hausgold::RequestError' do
        expect { action }.to raise_error(Hausgold::RequestError,
                                         /Trait not registered: unknown/)
      end
    end
  end
end
