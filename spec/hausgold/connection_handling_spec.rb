# frozen_string_literal: true

RSpec.describe Hausgold::ConfigurationHandling do
  let(:described_class) { Hausgold }

  before { described_class.reset_configuration! }

  it 'allows the access of the configuration' do
    expect(described_class.configuration).not_to be_nil
  end

  describe '#configure' do
    it 'yields the configuration' do
      expect do |block|
        described_class.configure(&block)
      end.to yield_with_args(described_class.configuration)
    end
  end

  describe '#reset_configuration!' do
    it 'resets the configuration to its defaults' do
      described_class.configuration.env = 'production'
      expect { described_class.reset_configuration! }.to \
        change { described_class.configuration.env }
    end
  end

  describe '#env' do
    it 'reads the configuration env' do
      described_class.configuration.env = 'local'
      expect(described_class.env).to be_eql('local')
    end

    it 'allows inquirer access' do
      described_class.configuration.env = 'production'
      expect(described_class.env.production?).to be(true)
    end
  end
end
