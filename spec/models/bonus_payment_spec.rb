require 'spec_helper'

describe BonusPayment, type: :model do
  let(:rank) { create(:rank) }
  let(:weekly_pay_period) { create(:weekly_pay_period) }

  describe '.with_ewallets' do
    let(:user1) { create(:user, ewallet_username: 'one@example.com') }
    let(:user2) { create(:user) }

    let!(:rank_achievement1) do
      create(:rank_achievement,
             rank:       rank,
             user:       user1,
             pay_period: weekly_pay_period)
    end
    let!(:rank_achievement2) do
      create(:rank_achievement,
             rank:       rank,
             user:       user2,
             pay_period: weekly_pay_period)
    end

    let!(:bonus_payment1) do
      create(:bonus_payment, pay_period: weekly_pay_period, user: user1)
    end
    let!(:bonus_payment2) do
      create(:bonus_payment, pay_period: weekly_pay_period, user: user2)
    end

    it 'returns bonus payments that belong to a user with ewallet' do
      expect(described_class.with_ewallets.map(&:user_id)).to eq([user1.id])
    end
  end
end
