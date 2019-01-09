# frozen_string_literal: true

RSpec.describe Hausgold::Client::IdentityApi do
  let(:instance) { described_class.new }
  let(:username) { 'identity-api@hausgold.de' }
  let(:password) { 'Oacbos8otAc=' }
  let(:password_params) { { email: username, password: password } }
  let(:bad_password_params) { { email: username, password: 'wrong' } }
  let(:scheme) { :password }
  let(:login) do
    lambda do |*args|
      meth = args.delete(:bang) ? :login! : :login
      auth = args.delete(:password)
      auth ||= args.delete(:refresh)
      auth ||= scheme
      instance.send(meth, scheme: auth, **args.last)
    end
  end
  let(:logout) do
    lambda do |*args|
      meth = args.delete(:bang) ? :logout! : :logout
      instance.send(meth, **args.last)
    end
  end
  let(:refresh_token) do
    login[:password, **password_params].refresh_token
  end
  let(:refresh_token_params) { { refresh_token: refresh_token } }
  let(:bad_refresh_token_params) { { refresh_token: 'b.a.d' } }

  describe '#login' do
    context 'with password scheme' do
      it 'responses a new Hausgold::Jwt instance' do
        expect(login[**password_params]).to be_a(Hausgold::Jwt)
      end

      it 'responses +nil+ on failed authentication' do
        expect(login[**bad_password_params]).to be(nil)
      end

      it 'resets initialization changes on top level' do
        expect(login[**password_params].changed?).to be(false)
      end

      it 'resets initialization changes on sub level' do
        expect(login[**password_params].user.changed?).to be(false)
      end
    end

    context 'with refresh token scheme' do
      let(:scheme) { :refresh }

      it 'responses a new Hausgold::Jwt instance' do
        expect(login[**refresh_token_params]).to be_a(Hausgold::Jwt)
      end

      it 'responses +nil+ on failed authentication' do
        expect(login[**bad_refresh_token_params]).to be(nil)
      end
    end
  end

  describe '#login!' do
    it 'responses a new Hausgold::Jwt instance' do
      expect(login[:bang, **password_params]).to \
        be_a(Hausgold::Jwt)
    end

    it 'raises on failed authentication' do
      expect { login[:bang, **bad_password_params] }.to \
        raise_error(Hausgold::AuthenticationError)
    end
  end

  describe '#logout' do
    it 'responses +true+ on success' do
      expect(logout[**refresh_token_params]).to be(true)
    end

    it 'responses +false+ on error' do
      expect(logout[**bad_refresh_token_params]).to be(false)
    end
  end

  describe '#logout!' do
    it 'responses +true+ on success' do
      expect(logout[:bang, **refresh_token_params]).to be(true)
    end

    it 'raises on error' do
      expect { logout[:bang, **bad_refresh_token_params] }.to \
        raise_error(Hausgold::RequestError,
                    /Token not a JWT, Token not a refresh token/)
    end
  end
end
