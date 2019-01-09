# frozen_string_literal: true

RSpec.describe Hausgold::Utils::Matchers do
  let(:uuid) { 'f4242ab0-d9d2-4f69-b1c0-0f94d035a219' }
  let(:gid) { "gid://identity-api/Entity/#{uuid}" }
  let(:email) { 'test@hausgold.de' }

  describe '#uuid?' do
    it 'detects valid uuid' do
      expect(described_class.uuid?(uuid)).to be(true)
    end

    it 'detects invalid uuid' do
      expect(described_class.uuid?('b-a-d')).to be(false)
    end

    it 'detects invalid uuid (odd stuff)' do
      expect(described_class.uuid?(Hausgold::Jwt)).to be(false)
    end
  end

  describe '#gid?' do
    it 'detects valid gid' do
      expect(described_class.gid?(gid)).to be(true)
    end

    it 'detects invalid gid' do
      expect(described_class.gid?('b-a-d')).to be(false)
    end

    it 'detects invalid gid (odd stuff)' do
      expect(described_class.gid?(Hausgold::Jwt)).to be(false)
    end
  end

  describe '#email?' do
    it 'detects valid email' do
      expect(described_class.email?(email)).to be(true)
    end

    it 'detects invalid email' do
      expect(described_class.email?('b-a-d')).to be(false)
    end

    it 'detects invalid email (odd stuff)' do
      expect(described_class.email?(Hausgold::Jwt)).to be(false)
    end
  end

  describe '#uuid' do
    it 'returns the uuid from a uuid string' do
      expect(described_class.uuid(uuid)).to be_eql(uuid)
    end

    it 'returns the uuid from a gid string' do
      expect(described_class.uuid(gid)).to be_eql(uuid)
    end

    it 'return nil when no matches found' do
      expect(described_class.uuid('b-a-d')).to be(nil)
    end

    it 'return nil when no matches found (odd stuff)' do
      expect(described_class.uuid(Hausgold::Jwt)).to be(nil)
    end
  end
end
