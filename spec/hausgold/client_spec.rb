# frozen_string_literal: true

RSpec.describe Hausgold::Client do
  let(:described_class) { Hausgold }

  describe '#resolve_app' do
    context 'with a configured alias' do
      it 'returns the input when no alias was resolved' do
        expect(described_class.resolve_app(:kundenportalApi)).to \
          be_eql(:'verkaeuferportal-api')
      end
    end

    context 'without a configured alias' do
      it 'returns the input when no alias was resolved' do
        expect(described_class.resolve_app(:identity_api)).to \
          be_eql(:'identity-api')
      end
    end
  end

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
