require 'spec_helper'

describe Invite do

  it 'autogenerates an id' do
    invite = create(:invite)
    expect(invite.id).to_not be_nil
  end
end
