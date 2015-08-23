require 'spec_helper'

describe PayPeriod, type: :model do
  let(:pay_period) { create(:weekly_pay_period) }

  describe '#distribute!' do
    let(:distribution) { create(:distribution) }
    let(:user) { create(:user, ewallet_username: 'doesnotexist@example.com') }

    let!(:rank_achievement) do
      create(:rank_achievement,
             rank:       create(:rank),
             user:       user,
             pay_period: pay_period)
    end

    let(:amount) { 111 }

    let!(:bonus_payment) do
      create(:bonus_payment,
             pay_period: pay_period,
             user:       user,
             amount:     amount)
    end

    let(:expected_ewallet_query) do
      {
        batch_id: distribution.id.to_s,
        payment:  {
          ref_id:   user.id,
          username: user.ewallet_username,
          amount:   amount }
      }
    end

    before do
      expect(pay_period)
        .to(receive(:create_distribution)
            .with(batch_id: pay_period.id.to_s + ':')
            .and_return(distribution))
    end

    context 'distribution succeeded' do
      before do
        allow_any_instance_of(EwalletClient)
          .to(receive(:ewallet_individual_load)
              .with(expected_ewallet_query).and_return(
                'm_Text' => 'OK'))
      end

      it 'should mark statuses as paid' do
        expect(pay_period.distribute!).to eq(true)
        expect(pay_period.bonus_payments.count).to eq(1)
        pay_period.bonus_payments.all.each do |bp|
          expect(bp.paid?).to eq(true)
        end
        expect(pay_period.distribution.paid?).to eq(true)
        expect(pay_period.distribution.distributed_at)
          .to be_within(1.second).of(Time.zone.now)
      end

      it 'should create and set a distribution' do
        pay_period.distribute!
        expect(pay_period.reload.distribution_id).not_to be_nil
      end
    end
  end
end
