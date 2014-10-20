require 'spec_helper'

describe PromoterMailer do

  it 'sends the invitation email' do
    build(:invite)
  end

end
