# frozen_string_literal: true

RSpec.describe Hausgold::Client::CalendarApi do
  let(:instance) { described_class.new }

  describe 'settings' do
    it 'got the correct application name' do
      expect(described_class.app_name).to be('calendar-api')
    end
  end

  describe '#locate' do
    context 'with task gid' do
      let(:uuid) { 'c150681f-c514-438a-8413-7c8f24a5f9dd' }
      let(:other_uuid) { 'c7ee24fc-4ccf-4205-b087-ff711d25ef3f' }
      let(:gid_raw) { "gid://calendar-api/Task/#{uuid}" }
      let(:other_gid_raw) { "gid://calendar-api/Task/#{other_uuid}" }
      let(:gid) { GlobalID.new(gid_raw) }

      it 'returns an Hausgold::Task instance' do
        expect(instance.locate(gid_raw)).to be_a(Hausgold::Task)
      end

      it 'returns the expected Hausgold::Task instance' do
        expect(instance.locate(gid).id).to be_eql(uuid)
      end

      it 'raises Hausgold::EntityNotFound when not found' do
        expect { instance.locate(other_gid_raw) }.to \
          raise_error(Hausgold::EntityNotFound)
      end
    end
  end

  %i[find_task find_task!].each do |meth|
    it "includes the #{meth} method" do
      expect(instance.respond_to?(meth)).to be(true)
    end
  end
end
