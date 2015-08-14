require 'spec_helper'

describe OneTimeBonus, type: :model do
  let(:rank) { create(:rank) }
  let(:weekly_pay_period) { create(:weekly_pay_period) }

  describe '#distribute!' do
    let(:distribution) { create(:distribution) }
    let(:bonus) { create(:one_time_bonus, distribution_id: distribution.id) }
    let(:user) { create(:user, ewallet_username: 'one@example.com') }

    let!(:rank_achievement) do
      create(:rank_achievement,
             rank:       rank,
             user:       user,
             pay_period: weekly_pay_period)
    end

    let(:amount) { 111 }

    let!(:bonus_payment) do
      create(:bonus_payment,
             pay_period: weekly_pay_period,
             user:       user,
             bonus:      bonus,
             amount:     amount)
    end

    let(:expected_ewallet_query) do
      {
        batch_id: 'powur:' + distribution.id.to_s,
        payment:  {
          ref_id:   user.id,
          username: user.ewallet_username,
          amount:   amount }
      }
    end

    before do
      expect(bonus)
        .to receive(:create_distribution).and_return(distribution)
    end

    context 'distribution succeeded' do
      before do
        allow_any_instance_of(EwalletClient)
          .to(receive(:ewallet_individual_load)
              .with(expected_ewallet_query).and_return(
                'm_Text' => 'OK'))
      end

      it 'should mark statuses as paid' do
        expect(bonus.distribute!).to eq(true)
        expect(bonus.bonus_payments.count).to eq(1)
        bonus.bonus_payments.all.each do |bp|
          expect(bp.paid?).to eq(true)
        end
        expect(bonus.distribution.paid?).to eq(true)
        expect(bonus.distribution.distributed_at)
          .to be_within(1.second).of(Time.zone.now)
      end

      it 'should create and set a distribution' do
        bonus.distribute!
        expect(bonus.distribution_id).not_to be_nil
      end
    end

    context 'when distribution fails' do
      before do
        allow_any_instance_of(BonusPayment)
          .to receive(:distribution_data).and_return(
            ref_id:   12,
            username: 'doesnotexist',
            amount:   34)
      end

      it 'should unset ewallet_username' do
        VCR.use_cassette('ewallet_load_not_found') do
          bonus.distribute!
          expect(user.reload.ewallet_username).to be_nil
        end
      end
    end
  end
end
