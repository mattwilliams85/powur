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
    create(:invite, invitor: user, first_name: 'Garry')
    create(:invite, invitor: user, last_name: 'Gareys')
    create(:invite, invitor: user, email: 'gary@example.org')

    results = Invite.search('gary')
    expect(results.size).to eq(3)
  end

end
