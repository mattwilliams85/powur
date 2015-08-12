require 'spec_helper'

describe OneTimeBonus, type: :model do
  let(:rank) { create(:rank) }
  let(:weekly_pay_period) { create(:weekly_pay_period) }

  describe '#distribute!' do
    let(:distribution) { create(:distribution) }
    let(:bonus) { create(:one_time_bonus, distribution_id: distribution.id) }
    let(:user1) { create(:user, ewallet_username: 'one@example.com') }
    let(:user2) { create(:user, ewallet_username: 'two@example.com') }

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
      create(:bonus_payment,
             pay_period: weekly_pay_period,
             user:       user1,
             bonus:      bonus,
             amount:     amount)
    end
    let!(:bonus_payment2) do
      create(:bonus_payment,
             pay_period: weekly_pay_period,
             user:       user2,
             bonus:      bonus,
             amount:     amount)
    end

    let(:expected_ewallet_query) do
      {
        batch_id: 'powur:' + distribution.id.to_s,
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
      expect(bonus)
        .to receive(:create_distribution).and_return(distribution)
      allow_any_instance_of(EwalletClient)
        .to receive(:ewallet_load).with(expected_ewallet_query).and_return(
          'm_Text' => 'OK'
        )
    end

    it 'should mark statuses as paid' do
      expect(bonus.distribute!).to eq(true)
      expect(bonus.bonus_payments.count).to eq(2)
      bonus.bonus_payments.all.each do |bp|
        expect(bp.paid?).to eq(true)
      end
      expect(bonus.distribution.paid?).to eq(true)
    end

    it 'should create and set a distribution' do
      bonus.distribute!
      expect(bonus.distribution_id).not_to be_nil
    end

    context 'when distribution fails' do
      before do
        allow_any_instance_of(EwalletClient)
          .to receive(:ewallet_load).with(expected_ewallet_query).and_return(
            'm_Text' => 'Error here'
          )
      end

      it 'should mark statuses as paid' do
        expect { bonus.distribute! }
          .to raise_error(RuntimeError, '{"m_Text"=>"Error here"}')
      end
    end
  end
end
