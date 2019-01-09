# frozen_string_literal: true

RSpec.describe Hausgold::Client::IdentityApi do
  let(:instance) { described_class.new }

  describe 'settings' do
    it 'got the correct application name' do
      expect(described_class.app_name).to be('identity-api')
    end
  end

  %i[login login! logout logout!].each do |meth|
    it "includes the #{meth} method" do
      expect(instance.respond_to?(meth)).to be(true)
    end
  end
end
