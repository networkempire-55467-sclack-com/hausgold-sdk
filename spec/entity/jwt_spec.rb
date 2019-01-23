# frozen_string_literal: true

RSpec.describe Hausgold::Jwt do
  let(:instance) do
    described_class.new(access_token: 'old').tap do |jwt|
      jwt.send(:changes_applied)
    end
  end

  describe '#entity_name' do
    it 'returns the correct entity name' do
      expect(instance.entity_name).to be_eql('Jwt')
    end
  end

  describe 'client' do
    it 'sets the client class as module accessor' do
      expect(described_class.client_class).to \
        be_eql(Hausgold::Client::IdentityApi)
    end
  end

  describe 'attributes' do
    describe '#_unmapped' do
      it 'creates an recursive open struct' do
        expect(described_class.new(test: true)._unmapped).to \
          be_a(RecursiveOpenStruct)
      end

      it 'collects all unknown attributes' do
        expect(described_class.new(test: true)._unmapped.to_h).to \
          be_eql(test: true)
      end

      it 'does not raise on unknown attributes' do
        expect { described_class.new(test: true) }.not_to raise_error
      end
    end

    describe '#persisted?' do
      it 'detects if no id attribute is defined' do
        expect(described_class.new.persisted?).to be(false)
      end
    end

    describe '#attributes' do
      it 'collects all known attributes/values as hash' do
        expect(instance.attributes).to \
          be_eql('access_token' => 'old',
                 'expires_in' => nil,
                 'refresh_token' => nil,
                 'token_type' => nil)
      end
    end

    describe '#attribute_names' do
      it 'collects all registed attribute names as symbols' do
        expect(described_class.attribute_names).to \
          be_eql(%i[token_type access_token refresh_token expires_in])
      end
    end

    describe 'dirty tracking' do
      it '#changed?' do
        expect { instance.access_token = 'new' }.to \
          change(instance, :changed?).from(false).to(true)
      end

      it '#changed' do
        instance.access_token = 'new'
        expect(instance.changed).to be_eql(['access_token'])
      end

      it '#changed_attributes' do
        instance.access_token = 'new'
        expect(instance.changed_attributes).to be_eql('access_token' => 'old')
      end

      it '#changes' do
        instance.access_token = 'new'
        expect(instance.changes).to be_eql('access_token' => %w[old new])
      end

      it '#attribute_changed?' do
        instance.access_token = 'new'
        expect(instance.access_token_changed?).to be(true)
      end

      it '#attribute_was' do
        instance.access_token = 'new'
        expect(instance.access_token_was).to be_eql('old')
      end

      it '#attribute_change' do
        instance.access_token = 'new'
        expect(instance.access_token_change).to be_eql(%w[old new])
      end

      describe '#clear_changes' do
        let(:instance) do
          described_class.new(access_token: 'old', user: { id: 'test' })
        end

        it 'clears the tracked changes on the top level' do
          expect { instance.clear_changes }.to \
            change(instance, :changed?).from(true).to(false)
        end

        it 'clears the tracked changes on sub levels' do
          expect { instance.clear_changes }.to \
            change(instance.user, :changed?).from(true).to(false)
        end

        it 'passes back itself for chaining' do
          expect(instance.clear_changes).to be(instance)
        end
      end
    end
  end

  describe 'associations' do
    it 'registers all associations' do
      expect(described_class.associations).to \
        be_eql(user: { class_name: Hausgold::User,
                       from: :user,
                       type: :has_one })
    end

    describe 'has_one user' do
      context 'without data' do
        it 'registers the user attribute' do
          expect(instance.respond_to?(:user)).to be(true)
        end

        it 'defaults to nil as user attribute' do
          expect(instance.user).to be(nil)
        end
      end

      context 'with data' do
        let(:user_params) { { id: 'test', unknown: true } }
        let(:instance) { described_class.new(user: user_params) }

        it 'creates a Hausgold::User instance' do
          expect(instance.user).to be_a(Hausgold::User)
        end

        it 'sets the known attributes' do
          expect(instance.user.id).to be_eql('test')
        end

        it 'sets the unknown attributes' do
          expect(instance.user._unmapped.unknown).to be(true)
        end
      end
    end
  end
end
