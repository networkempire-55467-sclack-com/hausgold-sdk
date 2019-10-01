# frozen_string_literal: true

RSpec.describe Hausgold::Pdf do
  let(:instance) { described_class.new }
  let(:wait_for_pdf_generation) do
    sleep(5) if ENV.fetch('VCR', 'true') == 'false'
  end

  describe '#entity_name' do
    it 'returns the correct entity name' do
      expect(instance.entity_name).to be_eql('Pdf')
    end
  end

  describe '#remote_entity_name' do
    it 'returns the correct remote entity name' do
      expect(instance.remote_entity_name).to be_eql('Pdf')
    end
  end

  describe 'client' do
    it 'sets the client class as module accessor' do
      expect(described_class.client_class).to \
        be_eql(Hausgold::Client::PdfApi)
    end
  end

  describe 'attributes' do
    let(:pdf) { build(:pdf) }

    describe 'media' do
      it 'acts as a string inquirer (print?)' do
        expect(pdf.media.print?).to be(false)
      end

      it 'acts as a string inquirer (screen?)' do
        expect(pdf.media.screen?).to be(true)
      end
    end

    describe 'landscape' do
      it 'allows the landscape? query' do
        expect(pdf.landscape?).to be(true)
      end

      it 'allows the opposite portrait? query' do
        expect(pdf.portrait?).to be(false)
      end
    end

    describe 'header_footer' do
      it 'allows the header_footer? query' do
        expect(pdf.header_footer?).to be(false)
      end
    end

    describe 'background' do
      it 'allows the background? query' do
        expect(pdf.background?).to be(true)
      end
    end

    describe 'format' do
      let(:pdf) { build(:pdf, format: 'A5') }

      it 'acts as a string inquirer (A4?)' do
        expect(pdf.format.A4?).to be(false)
      end

      it 'acts as a string inquirer (A5?)' do
        expect(pdf.format.A5?).to be(true)
      end
    end
  end

  describe '.create!' do
    let(:action) { described_class.create!(params) }

    context 'with valid params' do
      let(:params) { attributes_for :pdf }

      it 'sets the gid attribute correctly' do
        expect(action.gid).to \
          start_with('gid://pdf-api/Pdf/')
      end
    end

    context 'with invalid params' do
      let(:params) do
        attributes_for(:pdf).tap do |obj|
          obj[:url] = 'no-url'
        end
      end

      it 'raises an Hausgold::EntityInvalid error' do
        expect { action }.to \
          raise_error(Hausgold::EntityInvalid, /url is invalid/)
      end
    end
  end

  describe '.find' do
    let(:action) { described_class.find(id) }

    context 'with available document' do
      let(:create_pdf) { create(:pdf) }
      let(:id) { create_pdf.id }

      it 'changes the url attribute' do
        create_pdf
        wait_for_pdf_generation
        expect(action.url).to start_with('https://pdf-api-test.s3')
      end
    end

    context 'without found document' do
      let(:id) { '12573cf9dabe9d83ae7393e731106ef88d31e4dc' }

      it 'raises an Hausgold::EntityNotFound error' do
        expect { action }.to \
          raise_error(Hausgold::EntityNotFound, /#{id}/)
      end
    end
  end

  describe '#download' do
    let(:pdf) { create(:pdf) }

    before { pdf && wait_for_pdf_generation }

    context 'without destination' do
      let(:dest) { nil }

      it 'downloads the file' do
        expect(pdf.reload.download!(dest).size).to be > 100
      end
    end

    context 'with pathname destination' do
      let(:dest) { tmp_path.join('file.pdf') }

      it 'downloads the file' do
        pdf.reload.download(dest)
        expect(dest.size).to be > 100
      end
    end
  end
end
