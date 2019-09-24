# frozen_string_literal: true

RSpec.describe Hausgold::Client::IdentityApi do
  let(:instance) { described_class.new }
  let(:user) { instance.create_user!(build(:user)) }

  describe '#confirm_user' do
    context 'with data set' do
      it 'reloads the user instance' do
        expect { instance.confirm_user(user) }.to \
          change(user, :confirmed_at).from(nil).to(Time)
      end
    end

    context 'without data set' do
      it 'reloads the user instance (by id)' do
        empty = Hausgold::User.new(id: user.id)
        expect { instance.confirm_user(empty) }.to \
          change(empty, :email).from(nil).to(String)
      end

      it 'reloads the user instance (by email)' do
        empty = Hausgold::User.new(email: user.email)
        expect { instance.confirm_user(empty) }.to \
          change(empty, :id).from(nil).to(String)
      end
    end
  end

  describe '#confirm_user!' do
    context 'with unknown identifier' do
      let(:uuid) { '6a42dfc0-6d6d-4ef9-a726-9b0c7563a080' }

      it 'raises Hausgold::EntityNotFound when unknown' do
        msg = %(Couldn't find Hausgold::User with {:id=>\"#{uuid}\"})
        expect { instance.confirm_user!(Hausgold::User.new(id: uuid)) }.to \
          raise_error(Hausgold::EntityNotFound, msg)
      end
    end
  end

  %i[confirm lock recover recovered unconfirm unlock
     activate activated].each do |meth|
    it "includes the #{meth} method" do
      expect(instance.respond_to?("#{meth}_user")).to be(true)
    end

    it "includes the #{meth}! method" do
      expect(instance.respond_to?("#{meth}_user!")).to be(true)
    end
  end
end
