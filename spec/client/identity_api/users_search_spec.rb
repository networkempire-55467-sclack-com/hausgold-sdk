# frozen_string_literal: true

RSpec.describe Hausgold::Client::IdentityApi do
  let(:instance) { described_class.new }

  describe '#criteria_to_filters' do
    let(:action) { instance.criteria_to_filters(settings) }

    context 'with filters' do
      let(:settings) { criteria.where(test: true, email: '@') }

      it 'sets the correct filters (test)' do
        expect(action).to include(test: true)
      end

      it 'sets the correct filters (email)' do
        expect(action).to include(email: '@')
      end

      it 'sets the correct page' do
        expect(action).to include(page: 1)
      end

      it 'sets the correct per_page' do
        expect(action).to include(per_page: 250)
      end

      it 'sets the correct page on changed page cursor' do
        settings.page_cursor.next
        expect(action).to include(page: 2)
      end
    end

    context 'with offset' do
      let(:settings) { criteria.offset(1000) }

      it 'sets the correct page' do
        expect(action).to include(page: 5)
      end

      it 'sets the correct page on changed page cursor' do
        settings.page_cursor.next
        expect(action).to include(page: 6)
      end
    end

    context 'with limit' do
      let(:settings) { criteria.limit(300) }

      it 'sets the correct page' do
        expect(action).to include(page: 1)
      end

      it 'sets the correct page on changed page cursor' do
        settings.page_cursor.next
        expect(action).to include(page: 2)
      end
    end

    context 'with filters, offset and limit' do
      let(:settings) do
        criteria.where(test: true, email: '@').offset(1000).limit(300)
      end

      it 'sets the correct filters (test)' do
        expect(action).to include(test: true)
      end

      it 'sets the correct filters (email)' do
        expect(action).to include(email: '@')
      end

      it 'sets the correct page' do
        expect(action).to include(page: 5)
      end

      it 'sets the correct per_page' do
        expect(action).to include(per_page: 250)
      end

      it 'sets the correct page on changed page cursor' do
        settings.page_cursor.next
        expect(action).to include(page: 6)
      end
    end
  end

  describe '#search_users' do
    let(:action) { instance.search_users(settings) }

    context 'without filters' do
      let(:settings) { criteria.limit(2) }

      it 'returns nil' do
        expect(action).to be(nil)
      end
    end

    context 'with filters' do
      let(:settings) { criteria.where(text: '@').limit(2) }

      it 'returns an array' do
        expect(action).to be_a(Array)
      end

      it 'returns an array with two elements' do
        expect(action.count).to be(2)
      end

      it 'returns an array with Hausgold::User instances' do
        expect(action.first).to be_a(Hausgold::User)
      end

      it 'assigns the collection data to the Hausgold::User instances' do
        expect(action.first.gid).to start_with('gid://identity-api/User/')
      end
    end
  end

  describe '#search_users!' do
    let(:action) { instance.search_users!(settings) }

    context 'without filters' do
      let(:settings) { criteria.limit(2) }

      it 'raises an Hausgold::EntitySearchError' do
        expect { action }.to \
          raise_error(Hausgold::EntitySearchError,
                      /because: No filters for the search given/)
      end
    end

    context 'with filters' do
      let(:settings) { criteria.where(email: 'test@example.com').limit(1) }

      it 'returns an array' do
        expect(action).to be_a(Array)
      end

      it 'returns an array with one element' do
        expect(action.count).to be(1)
      end

      it 'returns an array with Hausgold::User instances' do
        expect(action.first).to be_a(Hausgold::User)
      end

      it 'returns the expected user instance' do
        expect(action.first.email).to be_eql('test@example.com')
      end
    end
  end
end
