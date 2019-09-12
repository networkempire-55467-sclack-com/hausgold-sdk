# frozen_string_literal: true

RSpec.describe Hausgold::Property do
  let(:instance) { described_class.new }

  describe '#entity_name' do
    it 'returns the correct entity name' do
      expect(instance.entity_name).to be_eql('Property')
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
                    source created_at updated_at geo_details])
      end
    end
  end
end
