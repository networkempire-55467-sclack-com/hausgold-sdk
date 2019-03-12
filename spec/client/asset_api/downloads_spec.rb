# frozen_string_literal: true

RSpec.shared_examples 'asset_api_client_download_to_expected_file' do
  it 'creates the expected file' do
    expect { instance.send(method, asset, dest) }.to \
      change { File.exist? dest }.from(false).to(true)
  end
end

RSpec.shared_examples 'asset_api_client_download_file' do
  it 'returns the expected instance' do
    expect(instance.send(method, asset, dest)).to be_a(file_type)
  end

  it 'downloads the a non-empty file' do
    file = instance.send(method, asset, dest)
    expect(file.size).to be > 1000
  end

  it 'downloads the expected file' do
    file = instance.send(method, asset, dest)
    expect(Digest::MD5.hexdigest(file.read)).to \
      be_eql('f5ca75b99f72f4d35a75e6d4924d8d33')
  end
end

RSpec.shared_examples 'asset_api_client_download' do
  context 'with a pathname destination' do
    let(:dest) { tmp_path.join('file') }
    let(:file_type) { File }

    include_examples 'asset_api_client_download_file'
    include_examples 'asset_api_client_download_to_expected_file'
  end

  context 'with a string destination' do
    let(:dest) { tmp_path.join('file').to_s }
    let(:file_type) { File }

    include_examples 'asset_api_client_download_file'
    include_examples 'asset_api_client_download_to_expected_file'
  end

  context 'with a file destination' do
    let(:dest) { File.open(tmp_path.join('file').to_s, 'w+') }
    let(:file_type) { File }

    include_examples 'asset_api_client_download_file'
  end

  context 'without a destination' do
    let(:dest) { nil }
    let(:file_type) { Tempfile }

    include_examples 'asset_api_client_download_file'
  end
end

RSpec.describe Hausgold::Client::AssetApi do
  let(:instance) { described_class.new }

  %i[download_asset].each do |meth|
    it "includes the #{meth} method" do
      expect(instance.respond_to?(meth)).to be(true)
    end

    it "includes the #{meth}! method" do
      expect(instance.respond_to?("#{meth}!".to_sym)).to be(true)
    end
  end

  describe '.download_asset' do
    let(:method) { :download_asset }
    let(:id) { '4530919a-3868-405e-8a84-001c7b9bb6b8' }
    let(:asset) { instance.find_asset(id) }
    let(:dest) { nil }

    context 'without findable entity' do
      let(:id) { '06474f95-4363-4490-8a63-6007ef756f29' }
      let(:asset) { build(:asset, :with_file_url, id: id) }

      it 'returns nil' do
        expect(instance.download_asset(asset, dest)).to be(nil)
      end
    end

    include_examples 'asset_api_client_download'

    context 'with private asset' do
      let(:asset) { create :asset, :private }

      it 'downloads the expected file' do
        file = instance.send(method, asset, dest)
        expect(Digest::MD5.hexdigest(file.read)).to \
          be_eql('f5ca75b99f72f4d35a75e6d4924d8d33')
      end
    end
  end

  describe '.download_asset!' do
    let(:method) { :download_asset! }
    let(:id) { '4530919a-3868-405e-8a84-001c7b9bb6b8' }
    let(:asset) { instance.find_asset(id) }
    let(:dest) { nil }

    context 'without findable entity' do
      let(:id) { '06474f95-4363-4490-8a63-6007ef756f29' }
      let(:asset) { build(:asset, :with_file_url, id: id) }

      it 'raises a Hausgold::EntityNotFound error' do
        expect { instance.download_asset!(asset, dest) }.to \
          raise_error(Hausgold::EntityNotFound)
      end
    end

    include_examples 'asset_api_client_download'
  end
end
