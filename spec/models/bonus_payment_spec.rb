require 'spec_helper'

describe BonusPayment, type: :model do
  describe '.distribute!' do
    let(:user1) { create(:user, ewallet_username: 'one@example.com') }
    let(:user2) { create(:user, ewallet_username: 'two@example.com') }

    let(:rank) { create(:rank) }
    let(:weekly_pay_period) { create(:weekly_pay_period) }

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

    let(:amount) { 111 }

    let!(:bonus_payment1) do
      create(:bonus_payment, pay_period: weekly_pay_period, user: user1, bonus: create(:bonus), amount: amount)
    end
    let!(:bonus_payment2) do
      create(:bonus_payment, pay_period: weekly_pay_period, user: user2, bonus: create(:bonus), amount: amount)
    end

    let(:expected_ewallet_query) do
      {
        batch_id: 'Bonus distribution on ' + Time.zone.now.strftime('%m/%d/%y'),
        payments: [
          { ref_id:   user1.id,
            username: user1.ewallet_username,
            amount:   amount },
          { ref_id:   user2.id,
            username: user2.ewallet_username,
            amount:   amount }
        ]
      }
    end

    before do
      allow_any_instance_of(EwalletClient)
        .to receive(:ewallet_load).with(expected_ewallet_query).and_return('ook')
    end

    it 'should mark statuses as paid' do
      expect(described_class.distribute!).to eq('ook')
      expect(described_class.count).to eq(2)
      described_class.all.each do |bp|
        expect(bp.paid?).to eq(true)
      end
    end
  end
end
