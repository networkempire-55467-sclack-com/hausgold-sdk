# frozen_string_literal: true

RSpec.describe Hausgold::Client::PropertyApi do
  let(:instance) { described_class.new }

  describe 'settings' do
    it 'got the correct application name' do
      expect(described_class.app_name).to be('property-api')
    end
  end
end
