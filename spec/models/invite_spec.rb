require 'spec_helper'

describe Invite do
  
  it 'defaults the id' do
    invite = Invite.new
    expect(invite.id.size).to eq(6)
  end
end
