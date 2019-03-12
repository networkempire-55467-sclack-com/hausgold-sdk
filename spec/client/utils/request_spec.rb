# frozen_string_literal: true

RSpec.describe Hausgold::ClientUtils::Request do
  let(:instance) { Hausgold::Client::Base.new }
  let(:req) { OpenStruct.new(headers: {}, options: OpenStruct.new) }
  let(:res) { OpenStruct.new(status: 500) }

  describe '#use_jwt' do
    let(:token) { Hausgold.identity.access_token }

    it 'adds the current identity as Authorization header' do
      expect { instance.use_jwt(req) }.to change(req, :headers) \
        .from({}).to('Authorization' => "Bearer #{token}")
    end
  end

  describe '#use_jwt_cookie' do
    let(:token) { Hausgold.identity.bare_access_token }

    it 'adds the current identity as HTTP cookie' do
      expect { instance.use_jwt_cookie(req) }.to change(req, :headers) \
        .from({}).to('Cookie' => "bare_access_token=#{token}")
    end
  end

  describe '#use_default_context' do
    let(:instance) do
      Hausgold::Client::IdentityApi.new.tap do |obj|
        allow(obj.connection).to receive(:post) do |&block|
          block.call(req)
          res
        end
      end
    end

    it 'adds the default context to the request options' do
      expect { instance.use_default_context(req) }.to \
        change(req.options, :context).from(nil).to(Hash)
    end

    it 'adds the client to the context' do
      instance.login
      expect(req.options.context[:client]).to be_eql('identity-api')
    end

    it 'adds the request action to the context' do
      instance.login
      expect(req.options.context[:action]).to be_eql('login')
    end

    it 'adds a request id to the context' do
      instance.login
      expect(req.options.context[:request_id]).to be_a(String)
    end
  end

  describe '#use_format' do
    it 'sets the correct header for json' do
      expect { instance.use_format(req, :json) }.to change(req, :headers) \
        .from({}).to('Content-Type' => 'application/json')
    end

    it 'sets the correct header for url_encoded' do
      expect { instance.use_format(req, :url_encoded) }.to \
        change(req, :headers)
        .from({}).to('Content-Type' => 'application/x-www-form-urlencoded')
    end

    it 'sets the correct header for multipart' do
      expect { instance.use_format(req, :multipart) }.to \
        change(req, :headers)
        .from({}).to('Content-Type' => 'multipart/form-data')
    end
  end
end
