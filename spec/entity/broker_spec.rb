# frozen_string_literal: true

RSpec.describe Hausgold::Broker do
  let(:instance) { described_class.new }
  let(:attributes) do
    %i[id gid customer_id email contact_email unconfirmed_email first_name
       last_name gender locale contact_id contact_phone created_at updated_at
       confirmed_at deactivated_at password]
  end

  describe '#entity_name' do
    it 'returns the correct entity name' do
      expect(instance.entity_name).to be_eql('Broker')
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
          be_eql('gid://maklerportal-api/User/uuid')
      end
    end

    describe '#to_gid' do
      let(:uuid) { '96092fa8-707d-4fe6-af5e-4898b9d87a90' }
      let(:instance) { described_class.find(uuid) }

      it 'returns a new URI::GID instance' do
        expect(instance.to_gid).to be_a(URI::GID)
      end

      it 'returns the correct Global Id' do
        expect(instance.to_gid.to_s).to \
          be_eql("gid://maklerportal-api/User/#{uuid}")
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

  describe 'persistence' do
    let(:valid) { build(:broker) }
    let(:invalid) { build(:broker, email: nil) }

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
          valid.update!(last_name: 'Mustermann')
        end

        it 'returns true on success' do
          expect(action).to be(true)
        end

        it 'assigns the response data (first level)' do
          expect { action }.to \
            change(valid, :last_name).from(valid.last_name).to('Mustermann')
        end
      end
    end
  end

  describe 'query' do
    describe '#find' do
      let(:uuid) { '96092fa8-707d-4fe6-af5e-4898b9d87a90' }
      let(:unknown_uuid) { '7775b36b-d4ab-4c69-9e24-352d6a35b8b9' }
      let(:gid) { "gid://maklerportal-api/User/#{uuid}" }
      let(:unknown_gid) { "gid://maklerportal-api/User/#{unknown_uuid}" }

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
                        'Found Hausgold::User instead of Hausgold::Broker')
        end
      end
    end

    describe '#find_by' do
      let(:broker) { described_class.find_by(text: '@example.com') }

      it 'returns a Hausgold::Broker instance' do
        expect(broker).to be_a(described_class)
      end

      it 'returns nil when not found' do
        expect(described_class.find_by(text: 'Unknown')).to be(nil)
      end
    end
  end

  describe '#full_name' do
    let(:valid) do
      build(:broker, first_name: 'Max', last_name: 'Mustermann')
    end

    it 'builds the correct full name' do
      expect(valid.full_name).to be_eql('Max Mustermann')
    end
  end
end
