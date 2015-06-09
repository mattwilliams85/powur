require 'spec_helper'

describe PayPeriod, type: :model do

  # before do
  #   DatabaseCleaner.clean
  # end

  describe '::generate_missing' do

    it 'backfills missing pay periods' do
      order_date = Date.current - 1.month
      create(:order, order_date: order_date)
      PayPeriod.generate_missing

      periods = MonthlyPayPeriod.all.order(start_date: :desc).entries
      expect(periods.size).to eq(1)
      expect(periods.first.id).to eq(order_date.strftime('%Y-%m'))

      periods = WeeklyPayPeriod.all.order(start_date: :desc).entries
      expect(periods.size).to eq(4)
      expected = (0...4).map { |i| (order_date + i.weeks).strftime('%GW%V') }
      expect(periods.map(&:id).sort).to eq(expected)
    end

  end

  describe '#process_at_sale_rank_bonuses!' do
  end

  # describe '#process_rank_achievements!' do

  #   before :each do
  #     create_list(:rank, 3)
  #   end

  #   describe 'lifetime' do

  #     before :each do
  #       @user = create(:user)
  #       path = create(:default_rank_path)
  #       @qual1 = create(:sales_qualification,
  #                       rank_id:     2,
  #                       time_period: :lifetime,
  #                       rank_path:   path,
  #                       quantity:    3)
  #       @qual2 = create(:sales_qualification,
  #                       rank_id:     2,
  #                       rank_path:   path,
  #                       time_period: :lifetime,
  #                       quantity:    1)
  #     end

  #     it 'does not create a lifetime achievement with only one qual. met' do
  #       order = create(:order,
  #                      product:  @qual1.product,
  #                      quantity: @qual1.quantity,
  #                      user:     @user)
  #       pay_period = order.weekly_pay_period

  #       pay_period.process_orders!

  #       achievement = @user.rank_achievements.first
  #       expect(achievement).to be_nil
  #     end

  #     it 'creates a lifetime achievement when all qualifications are met' do
  #     end
  #   end

  #   it 'creates pay period achievements' do
  #   end

  #   it 'creates rank achievements for group qualifications' do
  #   end

  # end

  # describe '#calculate!' do

  #   before :each do
  #     create_list(:rank, 3)
  #   end

  #   it 'creates order totals' do
  #     order_date = DateTime.current - 1.month
  #     order = create(:order, order_date: order_date)
  #     product = create(:product)

  #     parent = create(:user)
  #     user = create(:user, sponsor: parent)
  #     children = create_list(:user, 2, sponsor: user)

  #     create(:order, user: user,
  #            product: product, order_date: order_date - 10.minutes)
  #     create(:order, user: user,
  #            product: product, order_date: order_date - 1.month)

  #     1.upto(3) do |i|
  #       create(:order, user: children.first,
  #              product: product, order_date: order_date - i.minutes)
  #     end
  #     create(:order, user: children.last,
  #            product: product, quantity: 2, order_date: order_date - 5.minutes)

  #     pay_period = order.monthly_pay_period
  #     pay_period.queue_calculate

  #     order_total = OrderTotal.where(user_id:       user.id,
  #                                    product_id:    product.id,
  #                                    pay_period_id: pay_period.id).first

  #     expect(order_total).to_not be_nil
  #     expect(order_total.personal).to eq(1)
  #     expect(order_total.group).to eq(6)
  #     expect(order_total.personal_lifetime).to eq(2)
  #     expect(order_total.group_lifetime).to eq(7)

  #     order_total = OrderTotal.where(user_id:       children.first,
  #                                    product_id:    product.id,
  #                                    pay_period_id: pay_period.id).first

  #     expect(order_total).to_not be_nil
  #     expect(order_total.personal).to eq(3)
  #     expect(order_total.group).to eq(3)
  #     expect(order_total.personal_lifetime).to eq(3)
  #     expect(order_total.group_lifetime).to eq(3)
  #   end
  # end

  # describe '#disburse!' do

  #   before :each do
  #     create(:rank)
  #     @payment_user = create(:user)
  #     @pay_periods = [ 2, 3, 1 ].map do |i|
  #       pay_period = create(:weekly_pay_period, start_date: DateTime.current - i.weeks)
  #       create(:bonus_payment, pay_period: pay_period, user: @payment_user)
  #       pay_period
  #     end
  #   end

  #   it 'ensures a non-calculated pay period is ineligible for dispursement' do
  #     pay_period = MonthlyPayPeriod.find_or_create_by_date(DateTime.now)
  #     check_disbursable = pay_period.disbursable?
  #     expect(check_disbursable).to eq(false)
  #   end

  #   it 'ensures a calculated pay period is eligible for dispursement' do
  #     pay_period = MonthlyPayPeriod
  #                  .find_or_create_by_date(DateTime.now - 2.months)
  #     pay_period.disbursed_at = nil
  #     pay_period.calculated_at = DateTime.now - 1.month
  #     check_disbursable = pay_period.disbursable?
  #     expect(check_disbursable).to eq(true)
  #   end
  # end

  # describe '#order_totals' do

  #   before :each do
  #     @user = create(:user)
  #     @product = create(:product)
  #     @pay_period = WeeklyPayPeriod
  #                   .find_or_create_by_date(Date.current - 1.month)
  #   end

  #   def find_order_total(user = @user)
  #     @pay_period.order_totals.find do |ot|
  #       ot.product_id == @product.id && ot.user_id == user.id
  #     end
  #   end

  #   def add_order_total
  #     @pay_period.order_totals.create!(
  #       user:              @user,
  #       product:           @product,
  #       personal:          1,
  #       group:             1,
  #       personal_lifetime: 1,
  #       group_lifetime:    1)
  #   end

  #   it 'does not query the DB each additional time' do
  #     user = create(:user)
  #     create(:product)
  #     WeeklyPayPeriod.find_or_create_by_date(Date.current - 1.month)

  #     expect { find_order_total }.to make_database_queries
  #     expect { find_order_total }.to_not make_database_queries
  #     add_order_total
  #     expect { find_order_total }.to_not make_database_queries
  #     user = create(:user)
  #     expect { find_order_total(user) }.to_not make_database_queries
  #     expect { @pay_period.order_totals.each(&:pay_period) }
  #       .to_not make_database_queries
  #   end

  #   it 'calculates the correct group totals' do
  #     product = create(:product)
  #     order_date = DateTime.current - 3.months
  #     user = create(:user)
  #     children = create_list(:user, 2, sponsor: user)

  #     children.each do |child|
  #       create_list(:order, 3,
  #                   order_date: order_date,
  #                   user:       child,
  #                   product:    product)
  #     end

  #     pay_period = MonthlyPayPeriod.find_or_create_by_date(order_date)
  #     pay_period.process_orders!

  #     totals = pay_period.order_totals.find { |t| t.user_id == user.id }
  #     expect(totals.group_lifetime).to eq(6)
  #     expect(totals.group).to eq(6)

  #     children.each do |child|
  #       totals = pay_period.order_totals.find { |t| t.user_id == child.id }
  #       expect(totals.personal).to eq(3)
  #       expect(totals.group).to eq(3)
  #     end
  #   end

  # end

end
