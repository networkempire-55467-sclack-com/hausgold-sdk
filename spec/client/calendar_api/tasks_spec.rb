# frozen_string_literal: true

RSpec.describe Hausgold::Client::CalendarApi do
  let(:instance) { described_class.new }
  let(:uuid) { 'c150681f-c514-438a-8413-7c8f24a5f9dd' }
  let(:unknown_uuid) { '94cccc31-630e-40d5-8100-5ce6bc95fd12' }
  let(:gid) { "gid://calendar-api/Task/#{uuid}" }
  let(:valid) { Hausgold::Task.new(title: 'test', user_id: 'blub') }
  let(:invalid) { Hausgold::Task.new(title: 'test') }

  describe '#find_task' do
    context 'with uuid' do
      it 'returns a Hausgold::Task instance' do
        expect(instance.find_task(uuid)).to be_a(Hausgold::Task)
      end

      it 'returns the expected task' do
        expect(instance.find_task(uuid).id).to be_eql(uuid)
      end
    end

    context 'with gid' do
      it 'returns a Hausgold::Task instance' do
        expect(instance.find_task(gid)).to be_a(Hausgold::Task)
      end

      it 'returns the expected task' do
        expect(instance.find_task(gid).id).to be_eql(uuid)
      end
    end
  end

  describe '#find_task!' do
    it 'responses a new Hausgold::Jwt instance' do
      expect(instance.find_task!(uuid)).to be_a(Hausgold::Task)
    end

    it 'raises on failed authentication' do
      msg = %(Couldn't find Hausgold::Task with {:id=>"#{unknown_uuid}"})
      expect { instance.find_task!(unknown_uuid) }.to \
        raise_error(Hausgold::EntityNotFound, msg)
    end
  end

  describe '#create_task' do
    context 'with invalid data' do
      it 'returns nil when invalid' do
        expect(instance.create_task(invalid)).to be(nil)
      end
    end

    context 'with valid data' do
      it 'returns the original entity' do
        expect(instance.create_task(valid)).to be(valid)
      end

      it 'clears out the tracked changes' do
        expect { instance.create_task(valid) }.to \
          change(valid, :changed?).from(true).to(false)
      end

      it 'respond correctly to persisted?' do
        expect { instance.create_task(valid) }.to \
          change(valid, :persisted?).from(false).to(true)
      end

      it 'assigns the returned data' do
        expect { instance.create_task(valid) }.to \
          change(valid, :gid).from(nil).to(%r{^gid://calendar-api/.*})
      end
    end
  end

  describe '#create_task!' do
    context 'with invalid data' do
      it 'raises Hausgold::EntityInvalid when invalid' do
        msg = 'user_id is missing, user_id is empty'
        expect { instance.create_task!(invalid) }.to \
          raise_error(Hausgold::EntityInvalid, msg)
      end
    end
  end

  describe '#delete_task' do
    let(:task) { instance.create_task!(valid) }

    it 'returns the original entity' do
      expect(instance.delete_task(task)).to be(task)
    end

    it 'clears out the tracked changes' do
      task.title = 'new'
      expect { instance.delete_task(task) }.to \
        change(task, :changed?).from(true).to(false)
    end

    it 'resets potential changes' do
      task.title = 'new'
      expect { instance.delete_task(task) }.to \
        change(task, :title).from('new').to('test')
    end

    it 'respond correctly to persisted?' do
      expect { instance.delete_task(task) }.not_to \
        change(task, :persisted?).from(true)
    end

    it 'respond correctly to destroyed?' do
      expect { instance.delete_task(task) }.to \
        change(task, :destroyed?).from(false).to(true)
    end
  end

  describe '#delete!' do
    let(:uuid) { '6a42dfc0-6d6d-4ef9-a726-9b0c7563a080' }

    it 'raises Hausgold::EntityNotFound when unknown' do
      msg = %(Couldn't find Hausgold::Task with {:id=>\"#{uuid}\"})
      expect { instance.delete_task!(Hausgold::Task.new(id: uuid)) }.to \
        raise_error(Hausgold::EntityNotFound, msg)
    end
  end

  describe '#update_task' do
    let(:task) do
      valid.description = 'desc'
      instance.create_task!(valid)
    end

    context 'without changes' do
      it 'does no HTTP requests' do
        expect(instance).not_to receive(:update)
        instance.update_task(task)
      end
    end

    context 'with invalid changes' do
      it 'returns nil when invalid' do
        task.title = nil
        expect(instance.update_task(task)).to be(nil)
      end
    end

    context 'with valid changes' do
      before do
        task.title = 'new title'
        task.description = nil
      end

      it 'returns the original entity' do
        expect(instance.update_task(task)).to be(task)
      end

      it 'clears out the tracked changes' do
        expect { instance.update_task(task) }.to \
          change(task, :changed?).from(true).to(false)
      end

      it 'respond correctly to persisted?' do
        expect { instance.update_task(task) }.to \
          change(task, :persisted?).from(false).to(true)
      end

      it 'assigns the returned data (new title)' do
        expect { instance.update_task(task) }.not_to \
          change(task, :title).from('new title')
      end

      it 'assigns the returned data (new description)' do
        expect { instance.update_task(task) }.not_to \
          change(task, :description).from(nil)
      end

      it 'keeps the gid' do
        expect { instance.update_task(task) }.not_to change(task, :gid)
      end

      it 'keeps the id' do
        expect { instance.update_task(task) }.not_to change(task, :id)
      end
    end
  end

  describe '#update!' do
    let(:task) { instance.create_task!(valid) }

    context 'with invalid data' do
      it 'raises Hausgold::EntityInvalid when invalid' do
        task.title = nil
        msg = 'title is empty'
        expect { instance.update_task!(task) }.to \
          raise_error(Hausgold::EntityInvalid, msg)
      end
    end

    context 'with unknown identifier' do
      let(:uuid) { '6a42dfc0-6d6d-4ef9-a726-9b0c7563a080' }

      it 'raises Hausgold::EntityNotFound when unknown' do
        msg = %(Couldn't find Hausgold::Task with {:id=>\"#{uuid}\"})
        expect { instance.update_task!(Hausgold::Task.new(id: uuid)) }.to \
          raise_error(Hausgold::EntityNotFound, msg)
      end
    end
  end
end
