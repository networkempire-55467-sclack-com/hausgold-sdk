# frozen_string_literal: true

RSpec.describe Hausgold::NotificationToken do
  let(:instance) { described_class.new }

  describe '#entity_name' do
    it 'returns the correct entity name' do
      expect(instance.entity_name).to be_eql('NotificationToken')
    end
  end

  describe 'client' do
    it 'sets the client class as module accessor' do
      expect(described_class.client_class).to \
        be_eql(Hausgold::Client::IdentityApi)
    end
  end

  describe '.create!' do
    let(:action) { described_class.create!(params) }

    context 'with valid notification token params' do
      let(:params) { attributes_for :notification_token }

      it 'sets the gid attribute correctly' do
        expect(action.gid).to \
          start_with('gid://identity-api/NotificationToken/')
      end
    end

    context 'with invalid notification token params' do
      let(:params) do
        attributes_for(:notification_token).tap do |obj|
          obj[:user_id] = 'no-uuid'
        end
      end

      it 'raises an Hausgold::EntityInvalid error' do
        expect { action }.to \
          raise_error(Hausgold::EntityInvalid, /user_id is invalid/)
      end
    end
  end

  describe '.delete!' do
    let(:action) { described_class.delete!(id) }

    context 'with found notification token' do
      let(:id) { create(:notification_token).id }

      it 'deletes the token' do
        action
        expect { described_class.find(id) }.to \
          raise_error(Hausgold::EntityNotFound, /#{id}/)
      end
    end

    context 'without found notification token' do
      let(:id) { '59cb7865-0f45-49e6-bebf-e0f413480b40' }

      it 'raises an Hausgold::EntityNotFound error' do
        expect { action }.to \
          raise_error(Hausgold::EntityNotFound, /#{id}/)
      end
    end
  end
end
