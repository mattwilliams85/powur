require 'spec_helper'

describe OrderTotal, type: :model do

  describe '::generate_for_pay_period!' do

    before :each do
      @root = create(:user)
      @parent = create(:user, sponsor: @root)
      @children = create_list(:user, 2, sponsor: @parent)

      @product = create(:product)
      order_date = DateTime.current - 1.month
      create(:order, product: @product, user: @parent, order_date: order_date)
      create_list(:order, 2, product: @product, user: @children.first, order_date: order_date)
      create_list(:order, 3, product: @product, user: @children.last, order_date: order_date)
      @pay_period = MonthlyPayPeriod.find_or_create_by_date(order_date)
    end

    def assert_totals(order_totals, product_id, expected)
      expected.each do |user, totals|
        order_total = order_totals.find { |ot| ot.user_id == user.id && ot.product_id == product_id }
        expect(order_total).to_not be_nil
        expect(order_total.personal).to eq(totals[:personal])
        expect(order_total.group).to eq(totals[:group])
        expect(order_total.personal_lifetime).to eq(totals[:personal_lifetime])
        expect(order_total.group_lifetime).to eq(totals[:group_lifetime])
      end
    end

    it 'generates the correct records' do
      OrderTotal.generate_for_pay_period!(@pay_period)

      order_totals = OrderTotal.all.entries
      assert_totals(order_totals, @product.id,
        { @root           => { personal: 0, group: 6, personal_lifetime: 0, group_lifetime: 6 },
          @parent         => { personal: 1, group: 6, personal_lifetime: 1, group_lifetime: 6 },
          @children.first => { personal: 2, group: 2, personal_lifetime: 2, group_lifetime: 2 },
          @children.last  => { personal: 3, group: 3, personal_lifetime: 3, group_lifetime: 3 } })

      expect { OrderTotal.generate_for_pay_period!(@pay_period) }.to raise_error(ActiveRecord::RecordNotUnique)
    end

    it 'generates correct order totals for users with sales from previous months' do
      OrderTotal.generate_for_pay_period!(@pay_period)

      start_date = @pay_period.start_date + 1.month
      next_pay_period = MonthlyPayPeriod.find_or_create_by_date(start_date)

      create_list(:order, 2, product: @product, user: @parent, order_date: start_date)

      OrderTotal.generate_for_pay_period!(next_pay_period)

      order_totals = next_pay_period.order_totals.entries
      expect(order_totals.size).to eq(4)

      assert_totals(order_totals, @product.id,
        { @root           => { personal: 0, group: 2, personal_lifetime: 0, group_lifetime: 8 },
          @parent         => { personal: 2, group: 2, personal_lifetime: 3, group_lifetime: 8 },
          @children.first => { personal: 0, group: 0, personal_lifetime: 2, group_lifetime: 2 },
          @children.last  => { personal: 0, group: 0, personal_lifetime: 3, group_lifetime: 3 } })
    end

  end
end
