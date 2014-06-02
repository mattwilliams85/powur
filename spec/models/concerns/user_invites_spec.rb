require 'spec_helper'

describe UserInvites do

  it 'associates the user added to the invitee' do
    invite = create(:invite)

    params = { 
      email:      invite.email,
      first_name: invite.first_name,
      last_name:  invite.last_name,
      phone:      invite.phone,
      password:   'password',
      zip:        '92127' }

    # user = invite.invitor.add_invited_user(params)
  end
end