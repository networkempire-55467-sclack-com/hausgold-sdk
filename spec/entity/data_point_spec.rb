# frozen_string_literal: true

RSpec.describe Hausgold::DataPoint do
  let(:instance) { described_class.new }

  describe '#entity_name' do
    it 'returns the correct entity name' do
      expect(instance.entity_name).to be_eql('DataPoint')
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
      let(:params) { attributes_for :data_point }

      it 'sets the created_at attribute correctly' do
        expect(action.created_at).to be_a(Time)
      end
    end

    context 'with invalid params' do
      let(:params) do
        attributes_for(:data_point).tap do |obj|
          obj[:entity] = nil
        end
      end

      it 'raises an Hausgold::EntityInvalid error' do
        expect { action }.to \
          raise_error(Hausgold::EntityInvalid, /entity is missing/)
      end
    end
  end

  describe '.query' do
    let(:user_id) { '96092fa8-707d-4fe6-af5e-4898b9d87a90' }
    let(:args) do
      {
        entity: "gid://maklerportal-api/User/#{user_id}",
        context: 'is24',
        metric: 'visits',
        start_at: 30.days.ago,
        end_at: 1.day.ago,
        aggregation: :sum,
        internal: :day
      }
    end
    let(:action) { described_class.query(**args) }

    before { Timecop.freeze(Time.utc(2019, 3, 19, 12, 0, 0)) }

    after { Timecop.return }

    it 'returns a Hausgold::DataPointsResult instance' do
      expect(action).to be_a(Hausgold::DataPointsResult)
    end

    it 'returns the mapped data' do
      expect(action.data.count).to be(30)
    end

    it 'returns the mapped data, each a RecursiveOpenStruct instance' do
      expect(action.data.first).to be_a(RecursiveOpenStruct)
    end

    it 'returns the mapped total count' do
      expect(action.total_count).to be(30)
    end

    it 'returns the mapped total value' do
      expect(action.total_value).to match(/[1-9]\d+\.\d+/)
    end

    it 'returns the mapped aggregation' do
      expect(action.aggregation).to be(:sum)
    end
  end

  describe '.query!' do
    let(:user_id) { '99ef6d07-7a19-45c0-9be4-daed2147eb6e' }
    let(:args) do
      {
        entity: "gid://maklerportal-api/User/#{user_id}",
        context: 'user',
        metric: 'login'
      }
    end
    let(:action) { described_class.query!(**args) }

    it 'raises an Hausgold::EntityNotFound error' do
      expect { action }.to \
        raise_error(Hausgold::EntityNotFound, /#{user_id}.*user.*login/)
    end
  end
end
