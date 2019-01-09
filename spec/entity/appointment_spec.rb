# frozen_string_literal: true

RSpec.describe Hausgold::Appointment do
  let(:instance) { described_class.new }

  describe 'client' do
    it 'sets the client class as module accessor' do
      expect(described_class.client_class).to \
        be_eql(Hausgold::Client::CalendarApi)
    end
  end
end
