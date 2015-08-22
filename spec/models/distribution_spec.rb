require 'spec_helper'

describe Distribution, type: :model do
  let(:rank) { create(:rank) }
  let(:weekly_pay_period) { create(:weekly_pay_period) }

  describe '#distribute!' do
    let(:distribution) { create(:distribution) }
    let(:user) { create(:user, ewallet_username: 'ewallet_create_test@example.com') }

    let!(:rank_achievement) do
      create(:rank_achievement,
             rank:       rank,
             user:       user,
             pay_period: weekly_pay_period)
    end

    let(:amount1) { 111 }
    let(:amount2) { 2.2 }

    let!(:bonus_payment1) do
      create(:bonus_payment,
             pay_period: weekly_pay_period,
             user:       user,
             amount:     amount1)
    end
    let!(:bonus_payment2) do
      create(:bonus_payment,
             pay_period: weekly_pay_period,
             user:       user,
             amount:     amount2)
    end

    let(:expected_ewallet_query) do
      {
        batch_id: distribution.id.to_s,
        payment:  {
          ref_id:   user.id,
          username: user.ewallet_username,
          amount:   amount1 + amount2 }
      }
    end

    context 'distribution succeeded' do
      it 'should mark statuses as paid' do
        VCR.use_cassette('distribution_ewallet_load') do
          expect(distribution.distribute!([bonus_payment1, bonus_payment2]))
            .to eq(true)

          expect(bonus_payment1.reload.paid?).to eq(true)
          expect(bonus_payment1.reload.paid?).to eq(true)

          expect(distribution.paid?).to eq(true)
          expect(distribution.distributed_at)
            .to be_within(1.second).of(Time.zone.now)
        end
      end
    end

    context 'when distribution fails' do
      let(:user) { create(:user, ewallet_username: 'doesnotexist@example.com') }

      it 'should unset ewallet_username' do
        VCR.use_cassette('distribution_ewallet_not_found') do
          distribution.distribute!([bonus_payment1, bonus_payment2])
          expect(user.reload.ewallet_username).to be_nil
        end
      end
    end

    context 'when user does not have an ewallet' do
      it 'should try create an ewallet' do
        allow(bonus_payment1.user)
          .to receive(:ewallet?).and_return(false)
        allow(bonus_payment1.user)
          .to receive(:ewallet!).and_raise('ewallet creation failed')

        distribution.distribute!([bonus_payment1, bonus_payment2])
        expect(bonus_payment1.reload.pending?).to eq(true)
        expect(bonus_payment2.reload.pending?).to eq(true)
      end
    end
  end
end
