# frozen_string_literal: true

RSpec.describe Hausgold::Client::AssetApi do
  let(:instance) { described_class.new }

  describe 'settings' do
    it 'got the correct application name' do
      expect(described_class.app_name).to be('asset-api')
    end

    it 'sets the request format for create requests' do
      expect(described_class.format(:asset, :create)).to be(:multipart)
    end

    it 'keeps the default request formats for unconfigured actions' do
      expect(described_class.format(:asset, :find)).to be(:json)
    end
  end

  describe '.find_asset' do
    let(:id) { '4530919a-3868-405e-8a84-001c7b9bb6b8' }
    let(:url) do
      "http://asset-api.local/v1/assets/#{id}/download/avatar.jpg"
    end

    it 'sets the file url correctly' do
      expect(instance.find_asset(id).file_url).to be_eql(url)
    end
  end

  describe '.create_asset' do
    let(:asset) { build(:asset) }

    it 'sets the file url while uploading a new asset' do
      expect { instance.create_asset(asset) }.to \
        change(asset, :file_url).from(nil).to(%r{/download/avatar.jpg$})
    end
  end
end
