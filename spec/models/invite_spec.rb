require 'spec_helper'

describe Invite do
  it 'autogenerates an id' do
    invite = create(:invite)
    expect(invite.id).to_not be_nil
  end

  it 'autogenerates an expires' do
    invite = create(:invite)

    expect(invite.expires).to be > (DateTime.current + 23.hours)
  end

  it 'searches on invites' do
    user = create(:user)
    create(:invite, sponsor: user, first_name: 'Garry')
    create(:invite, sponsor: user, last_name: 'Gareys')
    create(:invite, sponsor: user, email: 'test+gary@test.com')

    results = Invite.search('gary')
    expect(results.size).to eq(3)
  end

  it 'does not allow an empty string on phone' do
    expect { create(:invite, phone: '') }
      .to raise_error(ActiveRecord::RecordInvalid)
  end

  describe '#accept' do
    let(:user) { invite.accept(params) }
    let(:invite) { create(:invite) }
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
