# frozen_string_literal: true

RSpec.describe Hausgold::GlobalId do
  let(:described_class) { Hausgold }
  let(:uuid) { 'c150681f-c514-438a-8413-7c8f24a5f9dd' }
  let(:other_uuid) { 'c7ee24fc-4ccf-4205-b087-ff711d25ef3f' }

  describe 'initialization' do
    let(:all_locators_count) { Hausgold::Configuration::API_NAMES.count }

    before { allow(GlobalID::Locator).to receive(:use) }

    after { Class.new { include Hausgold::GlobalId } }

    context 'with configured local app exclusion' do
      before { Hausgold.configuration.exclude_local_app_gid_locator = true }

      context 'with configured local app name' do
        before { Hausgold.configuration.app_name = 'identity-api' }

        it 'registers not all GID locators' do
          expect(GlobalID::Locator).to \
            receive(:use).exactly(all_locators_count - 1).times
        end
      end

      context 'without configured local app name (auto detection)' do
        before do
          add_fake_rails_app('IdentityApi')
          # We need to reset the +app_name+ with the configuration defaults,
          # because the defaults are not evaluated again on reset
          Hausgold.configuration.app_name = Hausgold.local_app_name
        end

        after { remove_fake_rails_app('IdentityApi') }

        it 'registers not all GID locators' do
          expect(GlobalID::Locator).to \
            receive(:use).exactly(all_locators_count - 1).times
        end
      end

      context 'without configured local app name (no auto detection)' do
        before { Hausgold.configuration.app_name = nil }

        it 'registers all GID locators' do
          expect(GlobalID::Locator).to \
            receive(:use).exactly(all_locators_count).times
        end
      end
    end

    context 'without configured local app exclusion' do
      before { Hausgold.configuration.exclude_local_app_gid_locator = false }

      context 'with configured local app name' do
        before { Hausgold.configuration.app_name = 'identity-api' }

        it 'registers all GID locators' do
          expect(GlobalID::Locator).to \
            receive(:use).exactly(all_locators_count).times
        end
      end

      context 'without configured local app name (auto detection)' do
        before do
          add_fake_rails_app('IdentityApi')
          # We need to reset the +app_name+ with the configuration defaults,
          # because the defaults are not evaluated again on reset
          Hausgold.configuration.app_name = Hausgold.local_app_name
        end

        after { remove_fake_rails_app('IdentityApi') }

        it 'registers all GID locators' do
          expect(GlobalID::Locator).to \
            receive(:use).exactly(all_locators_count).times
        end
      end

      context 'without configured local app name (no auto detection)' do
        before { Hausgold.configuration.app_name = nil }

        it 'registers all GID locators' do
          expect(GlobalID::Locator).to \
            receive(:use).exactly(all_locators_count).times
        end
      end
    end
  end

  describe '.locate' do
    let(:user_uuid) { 'bf136aed-0259-4458-8cf7-762553eebfc2' }
    let(:gid_raw) { "gid://calendar-api/Task/#{uuid}" }
    let(:gid_raw_user) { "gid://identity-api/User/#{user_uuid}" }
    let(:other_gid_raw) { "gid://calendar-api/Task/#{other_uuid}" }
    let(:gid) { GlobalID.new(gid_raw, namespace: Hausgold) }

    it 'returns an Hausgold::Task instance' do
      expect(described_class.locate(gid_raw)).to be_a(Hausgold::Task)
    end

    it 'returns an Hausgold::User instance' do
      expect(described_class.locate(gid_raw_user)).to be_a(Hausgold::User)
    end

    it 'returns the expected Hausgold::Task instance' do
      expect(described_class.locate(gid).id).to be_eql(uuid)
    end

    it 'raises Hausgold::EntityNotFound when not found' do
      expect { described_class.locate(other_gid_raw) }.to \
        raise_error(Hausgold::EntityNotFound)
    end
  end

  describe '.build_gid' do
    let(:app) { 'identity-api' }
    let(:gid) { "gid://#{app}/Task/#{uuid}" }

    it 'returns a URI::GID instance' do
      expect(described_class.build_gid(app, Hausgold::Task, uuid)).to \
        be_a(URI::GID)
    end

    context 'with entity class' do
      it 'builds the correct gid URI' do
        expect(described_class.build_gid(app, Hausgold::Task, uuid).to_s).to \
          be_eql(gid)
      end
    end

    context 'with entity string' do
      it 'builds the correct gid URI' do
        expect(described_class.build_gid(app, 'Task', uuid).to_s).to \
          be_eql(gid)
      end
    end

    context 'with entity symbol' do
      it 'builds the correct gid URI' do
        expect(described_class.build_gid(app, :task, uuid).to_s).to \
          be_eql(gid)
      end
    end
  end
end
