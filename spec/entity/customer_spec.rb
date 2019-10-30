# frozen_string_literal: true

RSpec.describe Hausgold::Customer do
  let(:instance) { described_class.new }
  let(:attributes) do
    %i[id gid email first_name last_name gender mobile phone created_at
       updated_at status password address]
  end

  describe '#entity_name' do
    it 'returns the correct entity name' do
      expect(instance.entity_name).to be_eql('Customer')
    end
  end

  describe '#remote_entity_name' do
    it 'returns the correct remote entity name' do
      expect(instance.remote_entity_name).to be_eql('User')
    end
  end

  describe 'global id' do
    describe '.to_gid' do
      it 'returns a new URI::GID instance' do
        expect(described_class.to_gid('uuid')).to be_a(URI::GID)
      end

      it 'returns the correct Global Id' do
        expect(described_class.to_gid('uuid').to_s).to \
          be_eql('gid://verkaeuferportal-api/User/uuid')
      end
    end

    describe '#to_gid' do
      let(:uuid) { '1c3ae1e2-097a-42a2-bc11-cc7f4ee9121e' }
      let(:instance) { described_class.find(uuid) }

      it 'returns a new URI::GID instance' do
        expect(instance.to_gid).to be_a(URI::GID)
      end

      it 'returns the correct Global Id' do
        expect(instance.to_gid.to_s).to \
          be_eql("gid://verkaeuferportal-api/User/#{uuid}")
      end
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
    it 'registers all associations' do
      expect(described_class.associations).to \
        be_eql(address: { class_name: Hausgold::Address,
                          from: :address,
                          type: :has_one,
                          persist: true })
    end

    describe 'has_one address' do
      context 'without data' do
        it 'registers the address attribute' do
          expect(instance.respond_to?(:address)).to be(true)
        end

        it 'defaults to nil as address attribute' do
          expect(instance.address).to be(nil)
        end
      end

      context 'with data' do
        let(:params) { { city: 'test', unknown: true } }
        let(:instance) { described_class.new(address: params) }

        it 'creates a Hausgold::Address instance' do
          expect(instance.address).to be_a(Hausgold::Address)
        end

        it 'sets the known attributes' do
          expect(instance.address.city).to be_eql('test')
        end

        it 'sets the unknown attributes' do
          expect(instance.address._unmapped.unknown).to be(true)
        end
      end
    end
  end

  describe 'persistence' do
    let(:valid) { build(:customer) }
    let(:invalid) { build(:customer, email: nil) }

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
        let(:address) do
          valid.address.attributes.merge(
            street: 'test', city: 'test', zipcode: '00000'
          )
        end
        let(:action) do
          valid.save!
          valid.update!(last_name: 'Mustermann', address: address)
        end

        it 'returns true on success' do
          expect(action).to be(true)
        end

        it 'assigns the response data (first level)' do
          expect { action }.to \
            change(valid, :last_name).from(valid.last_name).to('Mustermann')
        end

        it 'assigns the response data (nested level)' do
          expect { action }.to \
            change { valid.address.city }.from(valid.address.city).to('test')
        end
      end
    end
  end

  describe 'query' do
    describe '.find' do
      let(:uuid) { '1c3ae1e2-097a-42a2-bc11-cc7f4ee9121e' }
      let(:unknown_uuid) { '7775b36b-d4ab-4c69-9e24-352d6a35b8b9' }
      let(:gid) { "gid://verkaeuferportal-api/User/#{uuid}" }
      let(:unknown_gid) { "gid://verkaeuferportal-api/User/#{unknown_uuid}" }

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
                        'Found Hausgold::User instead of Hausgold::Customer')
        end
      end
    end

    describe '.find_by' do
      let(:customer) { described_class.find_by(text: '@example.com') }

      it 'returns a Hausgold::Customer instance' do
        expect(customer).to be_a(described_class)
      end

      it 'returns nil when not found' do
        expect(described_class.find_by(text: 'Unknown')).to be(nil)
      end
    end
  end

  describe 'notifications' do
    let(:valid) { build(:customer) }
    let(:property_id) { '3eacc8be-b17d-41cc-851a-62ed90c053ba' }

    describe '#property_created_notification' do
      let(:action) do
        valid.save!
        valid.property_created_notification!(property_id: property_id)
      end

      it 'returns true on success' do
        expect(action).to be(valid)
      end
    end
  end
end
