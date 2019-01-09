# frozen_string_literal: true

RSpec.describe Hausgold::Task do
  let(:instance) { described_class.new }
  let(:unknown_id) { '59cb7865-0f45-49e6-bebf-e0f413480b40' }

  describe '#entity_name' do
    it 'returns the correct entity name' do
      expect(instance.entity_name).to be_eql('Task')
    end
  end

  describe 'client' do
    it 'sets the client class as module accessor' do
      expect(described_class.client_class).to \
        be_eql(Hausgold::Client::CalendarApi)
    end
  end

  describe 'attributes' do
    describe '#attribute_names' do
      it 'collects all registed attribute names as symbols' do
        expect(described_class.attribute_names).to \
          be_eql(%i[id gid title description location due_date editable status
                    result type user_id reference_ids created_at updated_at
                    metadata alarms])
      end
    end
  end

  describe 'persistence' do
    let(:valid) { described_class.new(title: 'test', user_id: 'blub') }
    let(:invalid) { described_class.new(title: 'test') }

    describe '#new_record?' do
      it 'detects new records' do
        expect(described_class.new(id: nil).new_record?).to be(true)
      end

      it 'detects not new records' do
        expect(described_class.new(id: 'test').new_record?).to be(false)
      end
    end

    describe '#persisted?' do
      it 'detects the id field (nil)' do
        expect(described_class.new(id: nil).persisted?).to be(false)
      end

      it 'detects the id field (not nil)' do
        expect(described_class.new(id: 'test').persisted?).to be(false)
      end

      it 'detects when persisted' do
        entity = described_class.new(id: 'test')
        entity.changes_applied
        expect(entity.persisted?).to be(true)
      end
    end

    describe '#reload' do
      let(:params) { build(:task) }
      let(:task) { Hausgold.app(:calendar_api).create_task(params.dup) }
      let(:empty) { described_class.new(id: task.id) }

      it 'returns the same instance' do
        expect(task.reload).to be(task)
      end

      it 'raises Hausgold::EntityNotFound when not found' do
        empty.id = 'a34edc20-98f0-448c-948d-26e0398d1884'
        expect { empty.reload }.to raise_error(Hausgold::EntityNotFound)
      end

      context 'without previous data' do
        it 'assigns the missing data' do
          expect { empty.reload }.to \
            change(empty, :title).from(nil).to(params.title)
        end
      end

      context 'with previous data' do
        it 'resets changed data' do
          task.title = 'new'
          expect { task.reload }.to \
            change(task, :title).from('new').to(params.title)
        end
      end
    end

    describe '#save' do
      context 'with new instance' do
        let(:task) { build(:task) }

        it 'returns false when marked as destroyed' do
          task.mark_as_destroyed
          expect(task.save).to be(false)
        end

        it 'returns false on invalid data' do
          task = described_class.new
          expect(task.save).to be(false)
        end

        it 'returns true on success' do
          expect(task.save).to be(true)
        end

        it 'assigns the response data' do
          expect { task.save }.to change(task, :id).from(nil).to(String)
        end

        it 'performs the create_task call' do
          expect(task.client).to receive(:create_task).once
          task.save
        end

        it 'performs not the update_task call' do
          expect(task.client).not_to receive(:update_task)
          task.save
        end

        it 'changes the #new_record? output' do
          expect { task.save }.to \
            change(task, :new_record?).from(true).to(false)
        end
      end

      context 'with persisted instance' do
        let(:task) do
          build(:task).tap do |task|
            task.save
            task.title = 'something new'
          end
        end

        it 'returns false when marked as destroyed' do
          task.mark_as_destroyed
          expect(task.save).to be(false)
        end

        it 'returns false on invalid data' do
          task = described_class.new
          expect(task.save).to be(false)
        end

        it 'returns true on success' do
          expect(task.save).to be(true)
        end

        it 'assigns the response data' do
          # Sleep one second, to get the +update_at+ changed (otherwise its the
          # very same second, because we're blazingly fast <3)
          expect do
            sleep 1
            task.save
          end.to change(task, :updated_at)
        end

        it 'does not perform the update without changes' do
          task = build(:task).tap(&:save)
          expect(task.client).not_to receive(:update)
          task.save
        end

        it 'performs the update_task call' do
          expect(task.client).to receive(:update_task).once
          task.save
        end

        it 'performs not the create_task call' do
          expect(task.client).not_to receive(:create_task)
          task.save
        end

        it 'does changes the #new_record? output' do
          expect { task.save }.not_to \
            change(task, :new_record?).from(false)
        end

        it 'does changes the #persisted? output' do
          expect { task.save }.to \
            change(task, :persisted?).from(false).to(true)
        end
      end
    end

    describe '#save!' do
      context 'with new instance' do
        let(:task) { build(:task) }

        it 'raises Hausgold::EntityNotSaved when marked as destroyed' do
          task.mark_as_destroyed
          expect { task.save! }.to raise_error(Hausgold::EntityNotSaved)
        end

        it 'raises Hausgold::EntityNotSaved on invalid data' do
          task = described_class.new
          expect { task.save! }.to raise_error(Hausgold::EntityInvalid)
        end

        it 'returns true on success' do
          expect(task.save!).to be(true)
        end
      end

      context 'with persisted instance' do
        let(:task) { build(:task).tap(&:save) }

        it 'raises Hausgold::EntityNotSaved when marked as destroyed' do
          task.mark_as_destroyed
          expect { task.save! }.to raise_error(Hausgold::EntityNotSaved)
        end

        it 'raises Hausgold::EntityNotSaved on invalid data' do
          task = described_class.new
          expect { task.save! }.to raise_error(Hausgold::EntityInvalid)
        end

        it 'returns true on success' do
          expect(task.save!).to be(true)
        end
      end
    end

    describe '#delete' do
      let(:task) { build(:task).tap(&:save) }

      it 'returns false on unknown instances (no id set)' do
        expect(described_class.new.delete).to be(false)
      end

      it 'returns false on unknown instances (unknown id)' do
        expect(described_class.new(id: unknown_id).delete).to be(false)
      end

      it 'marks the instance as deleted' do
        expect { task.delete }.to change(task, :destroyed?).from(false).to(true)
      end

      it 'calls the delete_task client action' do
        expect(task.client).to receive(:delete_task).once
        task.delete
      end
    end

    describe '#delete!' do
      let(:task) { build(:task).tap(&:save) }

      it 'raises Hausgold::EntityNotFound on unknown instances (no id set)' do
        expect { described_class.new.delete! }.to \
          raise_error(Hausgold::EntityNotFound)
      end

      it 'raises Hausgold::EntityNotFound on unknown instances (unknown id)' do
        expect { described_class.new(id: unknown_id).delete! }.to \
          raise_error(Hausgold::EntityNotFound)
      end

      it 'marks the instance as deleted' do
        expect { task.delete! }.to \
          change(task, :destroyed?).from(false).to(true)
      end
    end

    describe '#update' do
      let(:task) { build(:task).tap(&:save) }

      it 'returns false on unknown instances (no id set)' do
        expect(described_class.new.update(title: 'new')).to be(false)
      end

      it 'returns false on unknown instances (unknown id)' do
        expect(described_class.new(id: unknown_id).update(title: 'new')).to \
          be(false)
      end

      it 'calls the client action, without changes' do
        expect(task.client).to receive(:update_task)
        task.update(title: 'something new', description: 'test')
      end

      it 'returns false when invalid data is set' do
        expect(task.update(title: nil)).to be(false)
      end

      it 'returns true when the update was successful' do
        expect(task.update(title: 'new')).to be(true)
      end
    end

    describe '#update!' do
      let(:task) { build(:task).tap(&:save) }

      it 'raises Hausgold::EntityInvalid on unknown instances (no id set)' do
        expect { described_class.new.update!(title: 'new') }.to \
          raise_error(Hausgold::EntityInvalid,
                      'user_id is missing, user_id is empty')
      end

      it 'raises Hausgold::EntityNotFound on unknown instances (unknown id)' do
        expect { described_class.new(id: unknown_id).update!(title: 'n') }.to \
          raise_error(Hausgold::EntityNotFound)
      end

      it 'returns false when invalid data is set' do
        expect { task.update!(title: nil) }.to \
          raise_error(Hausgold::EntityInvalid, /title is empty/)
      end

      it 'returns true when the update was successful' do
        expect(task.update!(title: 'new')).to be(true)
      end
    end

    describe '#update_attribute' do
      let(:task) { build(:task, title: 'old').tap(&:save) }

      it 'calls the client action, without changes' do
        expect(task.client).to receive(:update_task)
        task.update_attribute(:title, 'test')
      end

      it 'changes sets the new attribute' do
        expect { task.update_attribute(:title, 'new') }.to \
          change(task, :title).from('old').to('new')
      end

      it 'returns true when update was successful' do
        expect(task.update_attribute(:title, 'new')).to be(true)
      end

      it 'returns false on invalid changes' do
        expect(task.update_attribute(:title, nil)).to be(false)
      end
    end

    describe '#update_attribute!' do
      let(:task) { build(:task, title: 'old').tap(&:save) }

      it 'returns true when update was successful' do
        expect(task.update_attribute!(:title, 'new')).to be(true)
      end

      it 'raises Hausgold::EntityInvalid on invalid changes' do
        expect { task.update_attribute!(:title, nil) }.to \
          raise_error(Hausgold::EntityInvalid, /title is empty/)
      end
    end

    describe '.create' do
      let(:valid) { attributes_for(:task) }
      let(:invalid) { { title: nil } }

      context 'with single attribute set' do
        it 'returns an instance of Hausgold::Task' do
          expect(described_class.create(valid)).to \
            be_a(described_class)
        end

        it 'reloads the new entity' do
          expect(described_class.create(valid).id).to \
            be_a(String)
        end

        it 'returns the instance on invalid data' do
          expect(described_class.create(invalid)).to \
            be_a(described_class)
        end

        it 'yields when a block is given' do
          expect { |block| described_class.create(valid, &block) }.to \
            yield_with_args(described_class)
        end

        it 'allows to modify the instance with a block' do
          result = described_class.create(valid) do |task|
            task.title = 'new'
          end
          expect(result.title).to be_eql('new')
        end
      end

      context 'with multiple attribute sets' do
        it 'returns an array of Hausgold::Task instances' do
          expect(described_class.create([valid, valid])).to \
            all(be_a described_class)
        end

        it 'reloads the new entities' do
          expect(described_class.create([valid, valid]).map(&:id)).to \
            all(be_a(String))
        end

        it 'returns the array of instances on invalid data' do
          expect(described_class.create([valid, invalid])).to \
            all(be_a described_class)
        end

        it 'yields when a block is given' do
          expect { |block| described_class.create([valid, valid], &block) }.to \
            yield_control.twice
        end

        it 'allows to modify the instance with a block' do
          result = described_class.create([valid, valid]) do |task|
            task.title = 'new'
          end
          expect(result.map(&:title)).to all(be_eql('new'))
        end
      end
    end

    describe '.create!' do
      let(:valid) { attributes_for(:task) }
      let(:invalid) do
        { title: nil, user_id: '1fa16e8f-f714-4c9d-807a-b23c6e2192d3' }
      end

      context 'with single attribute set' do
        it 'returns an instance of Hausgold::Task' do
          expect(described_class.create!(valid)).to \
            be_a(described_class)
        end

        it 'raises an Hausgold::EntityInvalid on invalid data' do
          expect { described_class.create!(invalid) }.to \
            raise_error(Hausgold::EntityInvalid,
                        'title is missing, title is empty')
        end
      end

      context 'with multiple attribute sets' do
        it 'returns an array of Hausgold::Task instances' do
          expect(described_class.create!([valid, valid])).to \
            all(be_a described_class)
        end

        it 'raises an Hausgold::EntityInvalid on invalid data' do
          expect { described_class.create!([invalid, invalid]) }.to \
            raise_error(Hausgold::EntityInvalid,
                        'title is missing, title is empty')
        end
      end
    end

    describe '.update' do
      let(:task) { build(:task).tap(&:save) }
      let(:other_task) { build(:task).tap(&:save) }

      context 'with single attribute set' do
        it 'returns a Hausgold::Task instance' do
          expect(described_class.update(task.id, title: 'test')).to \
            be_a(described_class)
        end

        it 'returns the expected instance' do
          expect(described_class.update(task.id, title: 'test').id).to \
            be_eql(task.id)
        end

        it 'returns the instance on invalid changes' do
          expect(described_class.update(task.id, title: nil)).to \
            be_a(described_class)
        end

        it 'raises an ArgumentError when a instance is passed' do
          expect { described_class.update(task, title: 'test') }.to \
            raise_error(ArgumentError, /Hausgold::BaseEntity/)
        end
      end

      context 'with multiple attribute sets' do
        let(:valid) do
          {
            task.id => { title: 'new' },
            other_task.id => { title: 'new' }
          }
        end
        let(:invalid) do
          {
            task.id => { title: 'new' },
            other_task.id => { title: nil }
          }
        end

        it 'returns an array of Hausgold::Task instances' do
          expect(described_class.update(valid.keys, valid.values)).to \
            all(be_a described_class)
        end

        it 'reloads the new entities' do
          result = described_class.update(valid.keys, valid.values).map(&:id)
          expect(result).to all(be_a(String))
        end

        it 'returns the array of instances on invalid data' do
          expect(described_class.update(invalid.keys, invalid.values)).to \
            all(be_a described_class)
        end
      end
    end

    describe '.update!' do
      let(:task) { build(:task).tap(&:save) }
      let(:other_task) { build(:task).tap(&:save) }

      context 'with single attribute set' do
        it 'returns a Hausgold::Task instance' do
          expect(described_class.update!(task.id, title: 'test')).to \
            be_a(described_class)
        end

        it 'returns the expected instance' do
          expect(described_class.update!(task.id, title: 'test').id).to \
            be_eql(task.id)
        end

        it 'returns the instance on invalid changes' do
          expect { described_class.update!(task.id, title: nil) }.to \
            raise_error(Hausgold::EntityInvalid, 'title is empty')
        end

        it 'raises an ArgumentError when a instance is passed' do
          expect { described_class.update!(task, title: 'test') }.to \
            raise_error(ArgumentError, /Hausgold::BaseEntity/)
        end
      end

      context 'with multiple attribute sets' do
        let(:valid) do
          {
            task.id => { title: 'new' },
            other_task.id => { title: 'new' }
          }
        end
        let(:invalid) do
          {
            task.id => { title: 'new' },
            other_task.id => { title: nil }
          }
        end

        it 'returns an array of Hausgold::Task instances' do
          expect(described_class.update!(valid.keys, valid.values)).to \
            all(be_a described_class)
        end

        it 'raises an Hausgold::EntityInvalid on invalid data' do
          expect { described_class.update!(invalid.keys, invalid.values) }.to \
            raise_error(Hausgold::EntityInvalid, 'title is empty')
        end
      end
    end

    describe '.delete' do
      let(:task) { build(:task).tap(&:save) }
      let(:other_task) { build(:task).tap(&:save) }

      context 'with single id' do
        it 'returns a Hausgold::Task instance' do
          expect(described_class.delete(task.id)).to \
            be_a(described_class)
        end

        it 'returns the expected instance' do
          expect(described_class.delete(task.id).id).to \
            be_eql(task.id)
        end

        it 'marks the returned instance as destroyed' do
          expect(described_class.delete(task.id).destroyed?).to \
            be(true)
        end

        it 'passes back the data which was deleted' do
          expect(described_class.delete(task.id).title).to \
            be_eql(task.title)
        end

        it 'returns false on unknown ids' do
          expect(described_class.delete(unknown_id)).to \
            be(false)
        end
      end

      context 'with multiple ids' do
        it 'returns an array of Hausgold::Task instances' do
          expect(described_class.delete([task.id, other_task.gid])).to \
            all(be_a described_class)
        end

        it 'reloads the new entities' do
          result = described_class.delete([task.id, other_task.gid]).map(&:gid)
          expect(result).to all(match(%r{^gid://}))
        end
      end
    end

    describe '.delete!' do
      let(:task) { build(:task).tap(&:save) }
      let(:other_task) { build(:task).tap(&:save) }

      context 'with single id' do
        it 'returns the expected instance' do
          expect(described_class.delete!(task.id).id).to \
            be_eql(task.id)
        end

        it 'raises Hausgold::EntityNotFound on unknown id' do
          expect { described_class.delete!(unknown_id) } .to \
            raise_error(Hausgold::EntityNotFound)
        end
      end

      context 'with multiple ids' do
        it 'returns the expected instance' do
          result = described_class.delete!([task.id, other_task.gid]).map(&:id)
          expect(result).to be_eql([task.id, other_task.id])
        end

        it 'raises Hausgold::EntityNotFound on unknown id' do
          expect { described_class.delete!([task.id, unknown_id]) } .to \
            raise_error(Hausgold::EntityNotFound)
        end
      end
    end
  end

  describe 'query' do
    describe '#find' do
      let(:uuid) { 'c150681f-c514-438a-8413-7c8f24a5f9dd' }
      let(:unknown_uuid) { '94cccc31-630e-40d5-8100-5ce6bc95fd12' }
      let(:gid) { "gid://calendar-api/Task/#{uuid}" }
      let(:unknown_gid) { "gid://calendar-api/Task/#{unknown_uuid}" }

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
                        'Found Hausgold::User instead of Hausgold::Task')
        end
      end
    end
  end
end
