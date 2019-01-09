# frozen_string_literal: true

RSpec.describe Hausgold::Url do
  let(:described_class) { Hausgold }
  let(:uuid) { 'c150681f-c514-438a-8413-7c8f24a5f9dd' }
  let(:other_uuid) { 'c7ee24fc-4ccf-4205-b087-ff711d25ef3f' }

  describe '#locate' do
    let(:user_uuid) { 'bf136aed-0259-4458-8cf7-762553eebfc2' }
    let(:gid_raw) { "gid://calendar-api/Task/#{uuid}" }
    let(:gid_raw_user) { "gid://identity-api/User/#{user_uuid}" }
    let(:other_gid_raw) { "gid://calendar-api/Task/#{other_uuid}" }
    let(:gid) { GlobalID.new(gid_raw, namespace: Hausgold) }

    it 'returns an Hausgold::Task instance' do
      expect(described_class.locate(gid_raw)).to be_a(Hausgold::Task)
    end

    it 'returns an Hausgold::User instance' do
      expect(described_class.locate(gid_raw_user)).to be_a(Hausgold::User)
    end

    it 'returns the expected Hausgold::Task instance' do
      expect(described_class.locate(gid).id).to be_eql(uuid)
    end

    it 'raises Hausgold::EntityNotFound when not found' do
      expect { described_class.locate(other_gid_raw) }.to \
        raise_error(Hausgold::EntityNotFound)
    end
  end

  describe '#build_gid' do
    let(:app) { 'identity-api' }
    let(:gid) { "gid://#{app}/Task/#{uuid}" }

    it 'returns a URI::GID instance' do
      expect(described_class.build_gid(app, Hausgold::Task, uuid)).to \
        be_a(URI::GID)
    end

    context 'with entity class' do
      it 'builds the correct gid URI' do
        expect(described_class.build_gid(app, Hausgold::Task, uuid).to_s).to \
          be_eql(gid)
      end
    end

    context 'with entity string' do
      it 'builds the correct gid URI' do
        expect(described_class.build_gid(app, 'Task', uuid).to_s).to \
          be_eql(gid)
      end
    end

    context 'with entity symbol' do
      it 'builds the correct gid URI' do
        expect(described_class.build_gid(app, :task, uuid).to_s).to \
          be_eql(gid)
      end
    end
  end
end
