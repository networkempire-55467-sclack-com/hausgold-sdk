# frozen_string_literal: true

RSpec.describe Hausgold::DataPointEntity do
  let(:instance) { described_class.new }
  let(:wait_for_clock) do
    sleep(1) if ENV.fetch('VCR', 'true') == 'false'
  end

  describe '#entity_name' do
    it 'returns the correct entity name' do
      expect(instance.entity_name).to be_eql('DataPointEntity')
    end
  end

  describe '#remote_entity_name' do
    it 'returns the correct remote entity name' do
      expect(instance.remote_entity_name).to be_eql('DataPointEntity')
    end
  end

  describe 'client' do
    it 'sets the client class as module accessor' do
      expect(described_class.client_class).to \
        be_eql(Hausgold::Client::AnalyticApi)
    end
  end

  describe '.create!' do
    let(:action) { described_class.create!(params) }

    context 'with valid params' do
      let(:params) { attributes_for :data_point_entity }

      it 'sets the created_at attribute correctly' do
        expect(action.created_at).to be_a(Time)
      end
    end

    context 'with invalid params' do
      let(:params) do
        attributes_for(:data_point_entity).tap do |obj|
          obj[:gid] = nil
        end
      end

      it 'raises an Hausgold::EntityInvalid error' do
        expect { action }.to \
          raise_error(Hausgold::EntityInvalid, /gid is missing/)
      end
    end
  end

  describe 'updating via .create!' do
    let(:id) { '82a64334-5e99-433e-91c0-56431cf1694c' }
    let(:params) { attributes_for(:data_point_entity, entity_id: id) }
    let(:change) { params.dup.merge(permissions: { SecureRandom.uuid => 'r' }) }

    it 'updates the entity on subsequent calls' do
      initial = described_class.create!(params)
      wait_for_clock
      updated = described_class.create!(change)
      expect(initial.updated_at).not_to be_eql(updated.updated_at)
    end

    it 'keeps the same entity id on subsequent calls' do
      initial = described_class.create!(params)
      updated = described_class.create!(change)
      expect(initial.id).to be_eql(updated.id)
    end
  end

  describe '.delete' do
    before do
      allow(instance).to receive(:save)
      allow(instance.client).to receive(:delete_data_point_entity)
    end

    it 'calls the save method' do
      expect(instance).to receive(:save)
      instance.delete
    end
  end

  describe '.delete!' do
    before do
      allow(instance).to receive(:save)
      allow(instance.client).to receive(:delete_data_point_entity)
    end

    it 'calls the save! method' do
      expect(instance).to receive(:save!)
      instance.delete!
    end
  end
end
