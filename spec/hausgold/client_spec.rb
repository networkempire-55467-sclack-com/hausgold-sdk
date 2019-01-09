# frozen_string_literal: true

RSpec.describe Hausgold::Client do
  let(:described_class) { Hausgold }

  describe '#app' do
    context 'with a string' do
      it 'returns the correct client (kebab-case)' do
        expect(described_class.app('identity-api')).to \
          be_a(Hausgold::Client::IdentityApi)
      end

      it 'returns the correct client (camelCase)' do
        expect(described_class.app('identityApi')).to \
          be_a(Hausgold::Client::IdentityApi)
      end

      it 'returns the correct client (PascalCase)' do
        expect(described_class.app('IdentityApi')).to \
          be_a(Hausgold::Client::IdentityApi)
      end

      it 'returns the correct client (snake_case)' do
        expect(described_class.app('identity_api')).to \
          be_a(Hausgold::Client::IdentityApi)
      end
    end

    context 'with a symbol' do
      it 'returns the correct client (snake_case)' do
        expect(described_class.app(:identity_api)).to \
          be_a(Hausgold::Client::IdentityApi)
      end

      it 'returns the correct client (camelCase)' do
        expect(described_class.app(:identityApi)).to \
          be_a(Hausgold::Client::IdentityApi)
      end
    end
  end
end
