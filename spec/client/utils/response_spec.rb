# frozen_string_literal: true

RSpec.describe Hausgold::ClientUtils::Response do
  let(:instance) { Hausgold::Client::Base.new }
  let(:res) { ->(code) { RecursiveOpenStruct.new(status: code) } }

  describe '#status?' do
    context 'with ranges' do
      it 'responds true' do
        expect(instance.status?(res[400], code: 399..401)).to be(true)
      end

      it 'responds false' do
        expect(instance.status?(res[500], code: 399..401)).to be(false)
      end
    end

    context 'with arrays' do
      it 'responds true' do
        expect(instance.status?(res[500], code: [500, 200])).to be(true)
      end

      it 'responds false' do
        expect(instance.status?(res[500], code: [400])).to be(false)
      end
    end

    context 'with integers' do
      it 'responds true' do
        expect(instance.status?(res[500], code: 500)).to be(true)
      end

      it 'responds false' do
        expect(instance.status?(res[500], code: 400)).to be(false)
      end
    end
  end

  describe '#successful?' do
    it 'detects a failed response (false)' do
      expect(instance.successful?(res[400])).to be(false)
    end

    it 'detects a successful response (true)' do
      expect(instance.successful?(res[200])).to be(true)
    end

    it 'detects with a custom range (true)' do
      expect(instance.successful?(res[100], code: 0..200)).to be(true)
    end

    it 'detects with a custom range (false)' do
      expect(instance.successful?(res[500], code: 0..100)).to be(false)
    end
  end

  describe '#failed?' do
    it 'detects a failed response (true)' do
      expect(instance.failed?(res[400])).to be(true)
    end

    it 'detects a successful response (false)' do
      expect(instance.failed?(res[200])).to be(false)
    end

    it 'detects with a custom range (true)' do
      expect(instance.failed?(res[100], code: 0..200)).to be(true)
    end

    it 'detects with a custom range (false)' do
      expect(instance.failed?(res[500], code: 0..100)).to be(false)
    end
  end

  describe '#raise_on_errors' do
    it 'does not raise on successful requests' do
      expect { instance.raise_on_errors(res[200]) }.not_to raise_error
    end

    it 'raises on failed requests' do
      expect { instance.raise_on_errors(res[400]) }.to \
        raise_error(Hausgold::RequestError)
    end

    it 'raises on 404 statuses' do
      expect { instance.raise_on_errors(res[404]) }.to \
        raise_error(Hausgold::EntityNotFound)
    end
  end
end
