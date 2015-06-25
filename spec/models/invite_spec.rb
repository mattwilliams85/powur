require 'spec_helper'

describe Invite do
  let(:sponsor) { create(:certified_user) }
  let(:invite) { create(:invite, sponsor: sponsor) }

  it 'autogenerates an id' do
    expect(invite.id).to_not be_nil
  end

  it 'autogenerates an expires' do

    expect(invite.expires).to be > (DateTime.current + 23.hours)
  end

  it 'does not allow an empty string on phone' do
    expect { create(:invite, sponsor: sponsor, phone: '') }
      .to raise_error(ActiveRecord::RecordInvalid)
  end

  describe '#accept' do
    let(:user) { invite.accept(params) }
    let(:params) do
      {
        first_name: 'Donald',
        last_name: 'Duck',
        password: 'password',
        password_confirmation: 'password'
      }
    end
    let(:agreement) { double(version: 'mahalo') }

    context 'active tos exist' do
      before do
        allow(ApplicationAgreement).to receive(:current).and_return(agreement)
      end

      it 'should validate latest tos' do
        expect(user.errors.messages).to eq(
          tos: ['Please read and agree to the latest terms and conditions in the Application and Agreement']
        )
      end
    end

    context 'no currently active tos' do
      before do
        allow(ApplicationAgreement).to receive(:current).and_return(nil)
      end

      it 'should let create a user' do
        expect(user.errors.messages).to be_empty
      end
    end
  end
end
