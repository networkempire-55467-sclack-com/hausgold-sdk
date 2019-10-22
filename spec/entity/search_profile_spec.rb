# frozen_string_literal: true

RSpec.describe Hausgold::SearchProfile do
  let(:instance) { described_class.new }
  let(:attributes) do
    %i[id gid user_id usages property_types property_subtypes city zipcode
       perimeter price_from price_to year_of_construction_from
       year_of_construction_to amount_rooms_from amount_rooms_to
       living_space_from living_space_to land_size_from land_size_to created_at
       updated_at]
  end

  describe '#entity_name' do
    it 'returns the correct entity name' do
      expect(instance.entity_name).to be_eql('SearchProfile')
    end
  end

  describe '#remote_entity_name' do
    it 'returns the correct remote entity name' do
      expect(instance.remote_entity_name).to be_eql('SearchProfile')
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
        expect(described_class.attribute_names).to be_eql(attributes)
      end
    end
  end

  describe 'persistence' do
    let(:valid) { build(:search_profile) }
    let(:invalid) { build(:search_profile, user_id: nil) }

    describe '#save' do
      context 'with new instance' do
        it 'returns false on invalid data' do
          expect(invalid.save).to be(false)
        end

        it 'returns true on success' do
          expect(valid.save).to be(true)
        end

        it 'assigns the response data' do
          expect { valid.save }.to change(valid, :id).from(nil).to(String)
        end
      end

      context 'with persisted instance' do
        let(:action) do
          valid.save!
          valid.update!(city: 'Berlin')
        end

        it 'returns true on success' do
          expect(action).to be(true)
        end

        it 'assigns the response data (first level)' do
          expect { action }.to \
            change(valid, :city).from('Leipzig').to('Berlin')
        end
      end
    end
  end

  describe 'query' do
    let(:user_uuid) { 'f6d37ee5-66c7-4bdd-b987-f5261c01fa62' }
    let(:user_gid) { Hausgold::Customer.to_gid(user_uuid) }
    let(:valid) { build(:search_profile, user_id: user_gid) }
    let(:uuid) { valid.id }
    let(:gid) { valid.gid }
    let(:unknown_uuid) { '7771b36b-d4ab-4c69-9e24-352d6a35b8b9' }
    let(:unknown_gid) { described_class.to_gid(unknown_uuid).to_s }

    before { valid.save! }

    describe '#find' do
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
          gid = 'gid://identity-api/User/bf136aed-0259-4458-8cf7-762553eebfc2'
          expect { described_class.find(gid) }.to \
            raise_error(Hausgold::EntityNotFound,
                        'Found Hausgold::User instead of ' \
                        'Hausgold::SearchProfile')
        end
      end
    end

    describe '#find_by' do
      let(:search_profile) { described_class.find_by(user_id: user_gid) }

      it 'returns a Hausgold::SearchProfile instance' do
        expect(search_profile).to be_a(described_class)
      end

      it 'returns nil when not found' do
        expect(described_class.find_by(text: 'Unknown')).to be(nil)
      end
    end
  end
end
