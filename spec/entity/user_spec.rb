# frozen_string_literal: true

RSpec.describe Hausgold::User do
  let(:instance) { described_class.new }
  let(:attributes) do
    %i[id gid email type status last_login_at created_at updated_at
       confirmed_at locked_at recovery_at password password_confirmation]
  end

  describe '#entity_name' do
    it 'returns the correct entity name' do
      expect(instance.entity_name).to be_eql('User')
    end
  end

  describe '#remote_entity_name' do
    it 'returns the correct remote entity name' do
      expect(instance.remote_entity_name).to be_eql('User')
    end
  end

  describe 'client' do
    it 'sets the client class as module accessor' do
      expect(described_class.client_class).to \
        be_eql(Hausgold::Client::IdentityApi)
    end

    it 'enables access to the client instance' do
      expect(instance.client).to \
        be_a(Hausgold::Client::IdentityApi)
    end

    it 'caches the client instance' do
      expect(instance.client).to be(instance.client)
    end
  end

  describe 'attributes' do
    describe '#attributes' do
      let(:attributes_hash) do
        attributes.each_with_object({}) do |key, memo|
          memo[key.to_s] = nil
        end
      end

      it 'collects all known attributes/values as hash' do
        expect(instance.attributes).to \
          be_eql(attributes_hash)
      end
    end

    describe '#attribute_names' do
      it 'collects all registed attribute names as symbols' do
        expect(described_class.attribute_names).to \
          be_eql(attributes)
      end
    end
  end

  describe 'associations' do
    it 'has no registered associations' do
      expect(described_class.associations).to be_eql({})
    end
  end

  describe 'persistence' do
    describe '#persisted?' do
      it 'detects the id field (nil)' do
        expect(described_class.new(id: nil).persisted?).to be(false)
      end

      it 'detects the id field (not nil)' do
        expect(described_class.new(id: 'test').persisted?).to be(false)
      end

      it 'detects when persisted' do
        entity = described_class.new(id: 'test')
        entity.send(:changes_applied)
        expect(entity.persisted?).to be(true)
      end
    end

    describe '#destroyed?' do
      it 'detects when the entity is not marked as destroyed' do
        expect(described_class.new.destroyed?).to be(false)
      end

      it 'detects when the entity is marked as destroyed' do
        expect(described_class.new.mark_as_destroyed.destroyed?).to be(true)
      end
    end
  end

  describe 'query' do
    describe '.find' do
      let(:uuid) { 'bf136aed-0259-4458-8cf7-762553eebfc2' }
      let(:unknown_uuid) { '94cccc31-630e-40d5-8100-5ce6bc95fd12' }
      let(:gid) { "gid://identity-api/User/#{uuid}" }
      let(:unknown_gid) { "gid://identity-api/User/#{unknown_uuid}" }

      context 'with internal uuid' do
        it 'finds the expected instance' do
          expect(described_class.find(uuid).id).to be_eql(uuid)
        end

        it 'raises Hausgold::EntityNotFound when not found' do
          expect { described_class.find(unknown_uuid) }.to \
            raise_error(Hausgold::EntityNotFound)
        end
      end

      context 'with global id' do
        it 'finds the expected instance' do
          expect(described_class.find(gid).id).to be_eql(uuid)
        end

        it 'raises Hausgold::EntityNotFound when not found' do
          expect { described_class.find(unknown_gid) }.to \
            raise_error(Hausgold::EntityNotFound)
        end

        it 'raises Hausgold::EntityNotFound when result class vary' do
          gid = 'gid://calendar-api/Task/c150681f-c514-438a-8413-7c8f24a5f9dd'
          expect { described_class.find(gid) }.to \
            raise_error(Hausgold::EntityNotFound,
                        'Found Hausgold::Task instead of Hausgold::User')
        end
      end
    end
  end

  describe 'global id' do
    describe '.to_gid' do
      it 'returns a new URI::GID instance' do
        expect(described_class.to_gid('uuid')).to be_a(URI::GID)
      end

      it 'returns the correct Global Id' do
        expect(described_class.to_gid('uuid').to_s).to \
          be_eql('gid://identity-api/User/uuid')
      end
    end
  end

  describe '#identifier' do
    it 'raises when no identifier is present' do
      expect { described_class.new.identifier }.to \
        raise_error(ArgumentError, /identifier missing \(id or email\)/)
    end

    it 'returns a hash with the id (only id present)' do
      expect(described_class.new(id: 'test').identifier).to \
        be_eql(id: 'test')
    end

    it 'returns a hash with the email (only email present)' do
      expect(described_class.new(email: 'test').identifier).to \
        be_eql(email: 'test')
    end

    it 'returns a hash with the id (id and email present)' do
      user = described_class.new(id: 'test', email: 'test@example.com')
      expect(user.identifier).to be_eql(id: 'test')
    end
  end

  describe('#confirm') do
    let(:user) { Hausgold.app(:identity_api).create_user(build(:user)) }

    it 'confirms the user instance' do
      empty = described_class.new(email: user.email)
      expect { empty.confirm }.to \
        change(empty, :confirmed_at).from(nil).to(Time)
    end

    it 'reloads the user instance' do
      empty = described_class.new(email: user.email)
      expect { empty.confirm }.to change(empty, :id).from(nil).to(String)
    end

    it 'sends the metadata' do
      expect(user.client).to receive(:user_workflow)
        .with(:confirm, user, metadata: { env: :test })
      user.confirm(metadata: { env: :test })
    end
  end

  describe('#confirm!') do
    context 'with unknown identifier' do
      let(:uuid) { '6a42dfc0-6d6d-4ef9-a726-9b0c7563a080' }
      let(:user) { described_class.new(id: uuid) }

      it 'raises Hausgold::EntityNotFound when unknown' do
        msg = %(Couldn't find Hausgold::User with {:id=>\"#{uuid}\"})
        expect { user.confirm! }.to \
          raise_error(Hausgold::EntityNotFound, msg)
      end
    end
  end

  describe('#lock') do
    let(:user) { Hausgold.app(:identity_api).create_user(build(:user)) }

    it 'locks the user instance' do
      empty = described_class.new(email: user.email)
      expect { empty.lock }.to \
        change(empty, :locked_at).from(nil).to(Time)
    end
  end

  describe('#recover') do
    let(:user) { Hausgold.app(:identity_api).create_user(build(:user)) }

    it 'starts the account recovery of the user instance' do
      empty = described_class.new(email: user.email)
      expect { empty.recover }.to \
        change(empty, :recovery_at).from(nil).to(Time)
    end
  end

  describe '#unlock' do
    let(:password) { 'verySecure' }
    let(:user) { create(:user, password: password).tap(&:lock!) }
    let(:params) { { token: 'token', password: password } }

    it 'unlocks the user (stub)' do
      # We cannot know the unlock token, because of its only sent by mail
      expect(user.client).to receive(:unlock_user).with(user, **params).once
      user.unlock(**params)
    end
  end

  describe '#recovered' do
    let(:password) { 'moreSecure' }
    let(:user) { create(:user, password: password).tap(&:recover!) }
    let(:params) { { token: 'token', password: password } }

    it 'recoveres the user (stub)' do
      # We cannot know the recovery token, because of its only sent by mail
      expect(user.client).to receive(:recovered_user).with(user, **params).once
      user.recovered(**params)
    end
  end

  describe '#unconfirm' do
    let(:user) { create(:user).tap(&:confirm!) }

    it 'unconfirms the user' do
      expect { user.unconfirm }.to \
        change(user, :confirmed_at).from(Time).to(nil)
    end
  end

  describe '#activated' do
    let(:user) { create(:user) }

    context 'with password' do
      let(:params) { { token: 'token', password: 'password' } }

      it 'allows settings a new password' do
        expect(user.client).to receive(:activated_user)
          .with(user, good: Proc, **params)
        user.activated(**params)
      end
    end

    context 'without password' do
      let(:params) { { token: 'token' } }

      it 'allows keeping the old password' do
        expect(user.client).to receive(:activated_user)
          .with(user, good: Proc, **params)
        user.activated(**params)
      end
    end

    describe 'response handling', :vcr do
      let(:token) { '9f0703c61103b9bf9e781989877aacd2' }
      let(:user) do
        create(:user, email: 'activation-test@example.com',
                      status: :inactive).tap(&:activate!)
      end

      it 'returns a Hausgold::Jwt instance' do
        expect(user.activated!(token: token)).to be_a(Hausgold::Jwt)
      end
    end
  end
end
