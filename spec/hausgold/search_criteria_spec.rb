# frozen_string_literal: true

RSpec.describe Hausgold::SearchCriteria do
  describe 'handling' do
    describe '#find_by' do
      let(:action) { Hausgold::User.find_by(email: email) }
      let(:email) { 'test@example.com' }

      context 'without findings' do
        let(:email) { 'unknown@example.com' }

        it 'returns nil' do
          expect(action).to be(nil)
        end
      end

      context 'with findings' do
        it 'returns a Hausgold::User instance' do
          expect(action).to be_a(Hausgold::User)
        end

        it 'returns the correct user instance' do
          expect(action.email).to be_eql('test@example.com')
        end
      end
    end

    describe '#find_by!' do
      let(:action) { Hausgold::User.find_by!(email: email) }
      let(:email) { 'test@example.com' }

      context 'without filters' do
        it 'raise a Hausgold::EntitySearchError' do
          expect { Hausgold::User.find_by! }.to \
            raise_error(Hausgold::EntitySearchError,
                        /No filters for the search given/)
        end
      end

      context 'without findings' do
        let(:email) { 'unknown@example.com' }

        it 'raise a Hausgold::EntityNotFound error' do
          expect { action }.to \
            raise_error(Hausgold::EntityNotFound,
                        /Couldn't find Hausgold::User .*:email=>"#{email}"/)
        end
      end

      context 'with findings' do
        it 'returns a Hausgold::User instance' do
          expect(action).to be_a(Hausgold::User)
        end

        it 'returns the correct user instance' do
          expect(action.email).to be_eql('test@example.com')
        end
      end
    end

    describe '#exists?' do
      let(:action) { Hausgold::User.exists?(email: email) }
      let(:email) { 'test@example.com' }

      context 'without findings' do
        let(:email) { 'unknown@example.com' }

        it 'returns false' do
          expect(action).to be(false)
        end
      end

      context 'with findings' do
        it 'returns true' do
          expect(action).to be(true)
        end
      end
    end
  end
end
