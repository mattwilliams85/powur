require 'spec_helper'

describe ProductInvite, type: :model do
  let(:product_invite) { create(:product_invite) }

  describe '#save' do
    it 'generates a code' do
      expect(product_invite.code).not_to be_nil
      expect(product_invite.code.length).to be > 5
    end
  end
end
