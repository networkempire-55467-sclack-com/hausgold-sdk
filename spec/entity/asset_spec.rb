# frozen_string_literal: true

RSpec.describe Hausgold::Asset do
  let(:instance) { described_class.new }

  describe '#entity_name' do
    it 'returns the correct entity name' do
      expect(instance.entity_name).to be_eql('Asset')
    end
  end

  describe 'client' do
    it 'sets the client class as module accessor' do
      expect(described_class.client_class).to \
        be_eql(Hausgold::Client::AssetApi)
    end
  end

  describe 'attributes' do
    let(:asset) { build :asset }

    describe 'public' do
      it 'can be queried by public?' do
        expect(asset.public?).to be(true)
      end

      it 'can be queried by its opposite' do
        expect(asset.private?).to be(false)
      end

      it 'works with false values' do
        asset.public = false
        expect(asset.public?).to be(false)
      end

      it 'allows casting non-boolean value' do
        asset.public = 'FALSE'
        expect(asset.public).to be(false)
      end
    end

    describe 'category' do
      it 'casts to a StringInquirer' do
        asset.category = 'avatar'
        expect(asset.category).to be_a(ActiveSupport::StringInquirer)
      end

      it 'allows string inquiry access' do
        asset.category = 'avatar'
        expect(asset.category.avatar?).to be(true)
      end
    end
  end

  describe '.create' do
    context 'with direct file upload' do
      let(:params) { attributes_for :asset }

      it 'creates a new asset' do
        asset = described_class.create(params)
        expect(asset.file_url).to \
          be_eql("http://asset-api.local/v1/assets/#{asset.id}/download")
      end
    end

    context 'with file from URL' do
      let(:params) { attributes_for :asset, :with_file_from_url }

      it 'creates a new asset' do
        asset = described_class.create(params)
        expect(asset.file_url).to \
          be_eql("http://asset-api.local/v1/assets/#{asset.id}/download")
      end
    end
  end

  describe '#download' do
    let(:asset) { described_class.create(params) }

    context 'with public asset' do
      context 'with direct file upload' do
        let(:params) { attributes_for :asset }

        it 'downloads the expected file' do
          expect(Digest::MD5.hexdigest(asset.download.read)).to \
            be_eql('f5ca75b99f72f4d35a75e6d4924d8d33')
        end
      end

      context 'with file from URL' do
        let(:params) { attributes_for :asset, :with_file_from_url }

        it 'downloads the expected file' do
          expect(Digest::MD5.hexdigest(asset.download.read)).to \
            be_eql('f5ca75b99f72f4d35a75e6d4924d8d33')
        end
      end
    end

    context 'with private asset' do
      context 'with direct file upload' do
        let(:params) { attributes_for :asset, :private }

        it 'downloads the expected file' do
          expect(Digest::MD5.hexdigest(asset.download.read)).to \
            be_eql('f5ca75b99f72f4d35a75e6d4924d8d33')
        end
      end

      context 'with file from URL' do
        let(:params) { attributes_for :asset, :private, :with_file_from_url }

        it 'downloads the expected file' do
          expect(Digest::MD5.hexdigest(asset.download.read)).to \
            be_eql('f5ca75b99f72f4d35a75e6d4924d8d33')
        end
      end
    end
  end

  describe '#download!' do
    context 'with private asset and wrong identity' do
      let(:params) { attributes_for :asset, :private }

      it 'raises' do
        asset = described_class.create(params)
        Hausgold.identity(bare_access_token: 'invalid')
        expect { asset.download! }.to raise_error(Hausgold::EntityNotFound)
      end
    end
  end
end
