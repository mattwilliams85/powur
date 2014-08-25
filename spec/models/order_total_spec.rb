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
        expect(order_total.personal).to eq(totals.first)
        expect(order_total.group).to eq(totals.last)
      end
    end

    it 'generates the correct records' do
      OrderTotal.generate_for_pay_period!(@pay_period)

      order_totals = OrderTotal.all.entries
      assert_totals(order_totals, @product.id, 
        { @root           => [0, 6], 
          @parent         => [1, 6], 
          @children.first => [2, 2], 
          @children.last  => [3, 3] })


      expect { OrderTotal.generate_for_pay_period!(@pay_period) }.to raise_error(ActiveRecord::RecordNotUnique)
    end

  end
end
