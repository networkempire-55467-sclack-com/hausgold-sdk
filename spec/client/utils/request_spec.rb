# frozen_string_literal: true

RSpec.describe Hausgold::ClientUtils::Request do
  let(:instance) { Hausgold::Client::Base.new }

  describe '#use_jwt' do
    let(:req) { OpenStruct.new(headers: {}) }
    let(:token) { Hausgold.identity.access_token }

    it 'adds the current identity' do
      expect { instance.use_jwt(req) }.to change(req, :headers) \
        .from({}).to('Authorization' => "Bearer #{token}")
    end
  end
end
