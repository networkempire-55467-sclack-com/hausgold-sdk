# frozen_string_literal: true

RSpec.describe Hausgold::Property do
  let(:instance) { described_class.new }

  describe '#entity_name' do
    it 'returns the correct entity name' do
      expect(instance.entity_name).to be_eql('Property')
    end
  end

  describe '#remote_entity_name' do
    it 'returns the correct remote entity name' do
      expect(instance.remote_entity_name).to be_eql('Property')
    end
  end

  describe 'client' do
    it 'sets the client class as module accessor' do
      expect(described_class.client_class).to \
        be_eql(Hausgold::Client::PropertyApi)
    end
  end

  describe 'attributes' do
    describe '#attribute_names' do
      it 'collects all registed attribute names as symbols' do
        expect(described_class.attribute_names).to \
          be_eql(%i[id owner_id permissions object_details lead_id metadata
                    source created_at updated_at valuation_at
                    geo_details valuation searchable])
      end
    end
  end

  describe 'query' do
    describe '.sort' do
      let(:action) { proc { |**params| described_class.sort(**params) } }
      let(:details) do
        proc do |results, key|
          results.map(&:object_details).map { |details| details[key] }
        end
      end

      context 'with city asc' do
        it 'returns the properties in correct order' do
          expect(details[action[city: :asc], :city]).to \
            be_eql(%w[Amberg Augsburg Flemlingen Hof Leipzig Tröstau Trusetal])
        end
      end

      context 'with city desc' do
        it 'returns the properties in correct order' do
          expect(details[action[city: :desc], :city]).to \
            be_eql(%w[Trusetal Tröstau Leipzig Hof Flemlingen Augsburg Amberg])
        end
      end

      context 'with postal code desc' do
        it 'returns the properties in correct order' do
          expect(details[action[postal_code: :desc], :postal_code]).to \
            be_eql(%w[98596 95709 95032 92224 86150 76835 04319])
        end
      end
    end
  end
end
