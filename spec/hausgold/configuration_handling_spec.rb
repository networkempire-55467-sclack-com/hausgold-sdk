# frozen_string_literal: true

RSpec.describe Hausgold::ConfigurationHandling do
  let(:described_class) { Hausgold }

  before { described_class.reset_configuration! }

  it 'allows the access of the configuration' do
    expect(described_class.configuration).not_to be_nil
  end

  describe '.configure' do
    it 'yields the configuration' do
      expect do |block|
        described_class.configure(&block)
      end.to yield_with_args(described_class.configuration)
    end
  end

  describe '.reset_configuration!' do
    it 'resets the configuration to its defaults' do
      described_class.configuration.env = 'production'
      expect { described_class.reset_configuration! }.to \
        change { described_class.configuration.env }
    end
  end

  describe '.env' do
    it 'reads the configuration env' do
      described_class.configuration.env = 'local'
      expect(described_class.env).to be_eql('local')
    end

    it 'allows inquirer access' do
      described_class.configuration.env = 'production'
      expect(described_class.env.production?).to be(true)
    end
  end

  describe '.local_app_name' do
    context 'without Rails available' do
      it 'returns nil' do
        expect(described_class.local_app_name).to be(nil)
      end
    end

    context 'without Rails application available' do
      before { ::Rails = OpenStruct.new(application: nil) }

      after { Object.send(:remove_const, :Rails) }

      it 'returns nil' do
        expect(described_class.local_app_name).to be(nil)
      end
    end

    context 'with Rails application available' do
      before { add_fake_rails_app('IdentityApi') }

      after { remove_fake_rails_app('IdentityApi') }

      it 'returns the application name' do
        expect(described_class.local_app_name).to be_eql('identity-api')
      end
    end
  end

  describe '.api_names' do
    let(:all) do
      %i[
        asset-api calendar-api identity-api jabber pdf-api preferences
        property-api verkaeuferportal-api maklerportal-api analytic-api
        kundenportal-api
      ]
    end

    it 'returns the correct list of applications' do
      expect(described_class.api_names).to be_eql(all)
    end

    context 'with local app exclusion' do
      context 'with app_name configured' do
        before { Hausgold.configuration.app_name = 'identity-api' }

        it 'returns the partial list' do
          expect(described_class.api_names(exclude_local_app: true)).not_to \
            include(:'identity-api')
        end
      end

      context 'without app_name configured' do
        before { Hausgold.configuration.app_name = nil }

        it 'returns the full list' do
          expect(described_class.api_names(exclude_local_app: true)).to \
            be_eql(Hausgold::Configuration::ALL_API_NAMES)
        end
      end
    end

    context 'without local app exclusion' do
      context 'with app_name configured' do
        before { Hausgold.configuration.app_name = 'identity-api' }

        it 'returns the full list' do
          expect(described_class.api_names(exclude_local_app: false)).to \
            be_eql(Hausgold::Configuration::ALL_API_NAMES)
        end
      end

      context 'without app_name configured' do
        before { Hausgold.configuration.app_name = nil }

        it 'returns the full list' do
          expect(described_class.api_names(exclude_local_app: false)).to \
            be_eql(Hausgold::Configuration::ALL_API_NAMES)
        end
      end
    end
  end
end
