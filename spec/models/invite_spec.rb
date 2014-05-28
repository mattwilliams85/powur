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
end
