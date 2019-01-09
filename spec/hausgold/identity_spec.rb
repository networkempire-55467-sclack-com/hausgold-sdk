# frozen_string_literal: true

RSpec.shared_examples 'as_user_shared' do
  it 'yields the old identity' do
    expect { |block| described_class.as_user(input, &block) }.to \
      yield_with_args(anything, old_jwt)
  end

  it 'yields the new identity' do
    expect { |block| described_class.as_user(input, &block) }.to \
      yield_with_args(Hausgold::Jwt, anything)
  end

  it 'returns the result of the given block' do
    expect(described_class.as_user(input) { :result }).to be(:result)
  end

  it 'sets the new identity as global identity' do
    described_class.as_user(input) do |new, _old|
      expect(new).to be(Hausgold.identity)
    end
  end
end

RSpec.shared_examples 'as_user_expected_identity' do
  it 'yields the expected new identity (access token)' do
    described_class.as_user(input) do |new, _old|
      expect(new.access_token.size).to be > 50
    end
  end

  it 'yields the expected new identity (user id)' do
    described_class.as_user(input) do |new, _old|
      expect(new.user.id).to be_eql(uuid)
    end
  end

  it 'yields the expected new identity (user email)' do
    described_class.as_user(input) do |new, _old|
      expect(new.user.email).to be_eql(email)
    end
  end
end

RSpec.describe Hausgold::Identity do
  let(:described_class) { Hausgold }
  let(:identity) { ->(*args) { described_class.identity(*args) } }
  let(:jwt) { Hausgold::Jwt.new(access_token: 'test') }
  let(:other_jwt) { Hausgold::Jwt.new(access_token: 'another_test') }

  describe '#reset_identity!' do
    it 'resets the identity properly' do
      described_class.identity(jwt)
      expect { described_class.reset_identity! }.to \
        (change { described_class.class_variable_get(:@@identity) })
        .from(jwt).to(nil)
    end
  end

  describe '#identity' do
    before { described_class.reset_identity! }

    context 'with arguments' do
      it 'returns an Hausgold::Jwt instance' do
        expect(identity[access_token: 'test']).to \
          be_a(Hausgold::Jwt)
      end

      it 'allows to set the identity by attributes' do
        expect(identity[access_token: 'test'].access_token).to \
          be_eql('test')
      end

      it 'allows to set the identity with a given JWT' do
        expect(identity[jwt]).to be(jwt)
      end
    end

    context 'with block given' do
      it 'returns an Hausgold::Jwt instance' do
        result = described_class.identity { { access_token: 'test' } }
        expect(result).to be_a(Hausgold::Jwt)
      end

      it 'allows to set the identity by attributes' do
        result = described_class.identity { { access_token: 'test' } }
        expect(result.access_token).to be_eql('test')
      end

      it 'allows to set the identity with a given JWT' do
        result = described_class.identity { jwt }
        expect(result).to be(jwt)
      end
    end

    context 'with no cached JWT instance' do
      it 'performs a new authentication' do
        expect(described_class.identity).to be_a(Hausgold::Jwt)
      end

      it 'performs the authentication for the configured credentials' do
        expect(described_class.identity.user.email).to \
          be_eql('identity-api@hausgold.de')
      end
    end

    context 'with cached JWT instance' do
      it 'passes back the same JWT instance, once set' do
        described_class.identity(jwt)
        expect(described_class.identity).to be(jwt)
      end
    end
  end

  describe '#switch_identity' do
    before { described_class.identity(jwt) }

    it 'yields the old identity' do
      expect { |block| described_class.switch_identity(other_jwt, &block) }.to \
        yield_with_args(anything, jwt)
    end

    it 'yields the new identity' do
      expect { |block| described_class.switch_identity(other_jwt, &block) }.to \
        yield_with_args(other_jwt, anything)
    end

    it 'passes back the result of the block' do
      expect(described_class.switch_identity(jwt) { :test }).to be(:test)
    end

    it 'sets the given identity as default while running the block' do
      described_class.switch_identity(other_jwt) do
        expect(Hausgold.identity).to be(other_jwt)
      end
    end

    it 'resets to the previous identity after the block call' do
      expect { described_class.switch_identity(other_jwt) { true } }.not_to \
        change(Hausgold, :identity)
    end
  end

  describe '#as_user' do
    let(:uuid) { 'bf136aed-0259-4458-8cf7-762553eebfc2' }
    let(:gid) { "gid://identity-api/User/#{uuid}" }
    let(:email) { 'test@example.com' }
    let(:user) { Hausgold::User.new(id: uuid, email: email) }
    let(:old_jwt) { Hausgold::Jwt.new(access_token: 'old') }
    let(:jwt) { Hausgold::Jwt.new(access_token: 'test') }
    let(:params) { { access_token: 'test' } }
    let(:access_token) { 'test.test.test' }

    before { described_class.identity(old_jwt) }

    context 'with Hausgold::User' do
      let(:input) { user }

      include_examples 'as_user_shared'
      include_examples 'as_user_expected_identity'
    end

    context 'with uuid' do
      let(:input) { uuid }

      include_examples 'as_user_shared'
      include_examples 'as_user_expected_identity'
    end

    context 'with gid' do
      let(:input) { gid }

      include_examples 'as_user_shared'
      include_examples 'as_user_expected_identity'
    end

    context 'with email' do
      let(:input) { email }

      include_examples 'as_user_shared'
      include_examples 'as_user_expected_identity'
    end

    context 'with Hausgold::Jwt' do
      let(:input) { jwt }

      include_examples 'as_user_shared'
    end

    context 'with parameter hash' do
      let(:input) { params }

      include_examples 'as_user_shared'
    end

    context 'with access_token' do
      let(:input) { { access_token: access_token } }

      include_examples 'as_user_shared'
    end
  end
end
