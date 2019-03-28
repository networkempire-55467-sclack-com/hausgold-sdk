# frozen_string_literal: true

RSpec.describe Hausgold::Client::Base do
  let(:instance) { described_class.new }
  let(:test_client) { Class.new(described_class) }
  let(:res) { ->(code) { RecursiveOpenStruct.new(status: code) } }

  describe '#initialize' do
    it 'allows mass assignment' do
      instance = test_client.new(app_name: 'test')
      expect(instance.app_name).to be_eql('test')
    end
  end

  describe '#connection' do
    describe '#url_prefix' do
      before do
        instance.app_name = 'test-app'
      end

      it 'generates the correct URL (local env)' do
        Hausgold.configuration.env = :local
        expect(instance.connection.url_prefix.to_s).to \
          be_eql('http://test-app.local/')
      end

      it 'generates the correct URL (canary env)' do
        Hausgold.configuration.env = :canary
        expect(instance.connection.url_prefix.to_s).to \
          be_eql('https://test-app.canary.hausgold.de/')
      end

      it 'generates the correct URL (production env)' do
        Hausgold.configuration.env = :production
        expect(instance.connection.url_prefix.to_s).to \
          be_eql('https://test-app.hausgold.de/')
      end
    end
  end

  describe '#locate' do
    context 'with unknown entity' do
      let(:uuid) { 'bd28d15e-8b8d-43bd-b737-205756e04ead' }
      let(:gid) { "gid://calendar-api/Unknown/#{uuid}" }

      it 'raises a Hausgold::NotImplementedError' do
        msg = 'Hausgold::Client::Base#find_unknown! not yet implemented'
        expect { instance.locate(gid) }.to \
          raise_error(Hausgold::NotImplementedError, msg)
      end
    end
  end

  %i[find search update create delete].each do |method|
    describe "##{method}" do
      it 'raises because it not implemented on the base client' do
        expect { described_class.new.send(method) }.to \
          raise_error(Hausgold::NotImplementedError,
                      "Hausgold::Client::Base##{method} not yet implemented")
      end
    end
  end

  describe '#format' do
    before { described_class.action_formats = nil }

    after { described_class.action_formats = nil }

    it 'returns the default for unconfigured actions' do
      expect(described_class.new.format(:test)).to be_eql(:json)
    end

    it 'returns the configured format' do
      described_class.action_formats = { test: :multipart }
      expect(described_class.new.format(:test)).to be_eql(:multipart)
    end
  end

  describe '.format' do
    before { described_class.action_formats = nil }

    after { described_class.action_formats = nil }

    it 'returns the default for unconfigured actions' do
      expect(described_class.format(:test)).to be_eql(:json)
    end

    it 'returns the configured format' do
      described_class.action_formats = { test: :multipart }
      expect(described_class.format(:test)).to be_eql(:multipart)
    end
  end

  describe '.default_formats' do
    let(:expected) do
      {
        create: :json,
        delete: :json,
        find: :json,
        search: :json,
        update: :json,
        reload: :json
      }
    end

    it 'returns a reusable action format hash' do
      expect(described_class.default_formats).to match(expected)
    end
  end
end
