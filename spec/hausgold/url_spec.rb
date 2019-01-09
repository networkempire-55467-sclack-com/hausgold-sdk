# frozen_string_literal: true

RSpec.describe Hausgold::Url do
  let(:described_class) { Hausgold }

  before { described_class.reset_configuration! }

  describe '#app_domain' do
    it 'formats the domain correctly (default env)' do
      expect(described_class.app_domain('asset-api')).to \
        be_eql('asset-api.canary.hausgold.de')
    end

    it 'formats the domain correctly (canary env)' do
      expect(described_class.app_domain('pdf-api', 'canary')).to \
        be_eql('pdf-api.canary.hausgold.de')
    end

    it 'formats the domain correctly (production env)' do
      described_class.configuration.env = :production
      expect(described_class.app_domain('calendar-api')).to \
        be_eql('calendar-api.hausgold.de')
    end

    it 'formats the domain correctly (local env)' do
      expect(described_class.app_domain('jabber', 'local')).to \
        be_eql('jabber.local')
    end

    it 'raises when unknown env is given' do
      expect { described_class.app_domain('jabber', 'test') }.to \
        raise_error(/Environment test unknown/)
    end
  end

  describe '#app_url' do
    it 'formats the domain correctly (default env)' do
      expect(described_class.app_url('asset-api')).to \
        be_eql('https://asset-api.canary.hausgold.de')
    end

    it 'formats the domain correctly (canary env)' do
      expect(described_class.app_url('pdf-api', 'canary')).to \
        be_eql('https://pdf-api.canary.hausgold.de')
    end

    it 'formats the domain correctly (production env)' do
      described_class.configuration.env = :production
      expect(described_class.app_url('calendar-api')).to \
        be_eql('https://calendar-api.hausgold.de')
    end

    it 'formats the domain correctly (local env)' do
      expect(described_class.app_url('jabber', 'local')).to \
        be_eql('http://jabber.local')
    end

    it 'raises when unknown env is given' do
      expect { described_class.app_url('jabber', 'test') }.to \
        raise_error(/Environment test unknown/)
    end
  end
end
