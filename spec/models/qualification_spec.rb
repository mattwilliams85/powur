require 'spec_helper'

describe Qualification, type: :model do

  describe '#met?' do
    def create_order_total(total, user = nil)
      attrs = { 
        product:            @product,
        personal:           total,
        group:              total,
        personal_lifetime:  total,
        group_lifetime:     total }
      attrs[:user] = user if user
      create(:order_total, attrs)
    end

    describe SalesQualification do
      before :each do
        @product = create(:product)
        @period_qual = create(:sales_qualification,
          product:  @product,
          period:   :pay_period,
          quantity: 3)
        @life_qual = create(:sales_qualification,
          product:  @product,
          period:   :lifetime,
          quantity: 3)
      end

      it 'returns false when the totals are not met' do
        [ 0, 2 ].each do |i|
          [ @period_qual, @life_qual ].each do |q|
            order_total = create_order_total(i)

            result = q.met?(order_total.user_id, order_total.pay_period)
            expect(result).to_not be
          end
        end
      end

      it 'returns true when the totals are met' do
        [ 3, 5 ].each do |i|
          [ @period_qual, @life_qual ].each do |q|
            order_total = create_order_total(i)

            result = q.met?(order_total.user_id, order_total.pay_period)
            expect(result).to be
          end
        end
      end
    end

    describe GroupSalesQualification do
      before :each do
        @product = create(:product)
        @period_qual = create(:group_sales_qualification, product: @product, period: :pay_period, quantity: 3, max_leg_percent: nil)
        @life_qual = create(:group_sales_qualification, product: @product, period: :lifetime, quantity: 3, max_leg_percent: nil)
        @max_leg_period_qual = create(:group_sales_qualification, product: @product, period: :pay_period, quantity: 3, max_leg_percent: 60)
      end

      it 'returns false when the user has no downline sales' do
        order_total = create_order_total(5)
        [ @period_qual, @life_qual ].each do |q|
          result = q.met?(order_total.user_id, order_total.pay_period)

          expect(result).to_not be
        end
      end

      def create_order_total_with_group(child_order_count, n = 2)
        order_total = create_order_total(3)
        children = create_list(:user, n, sponsor: order_total.user)
        children.each { |c| create_order_total(child_order_count, c) }
        order_total
      end

      it 'returns false when the users downline sales are not enough' do
        order_total = create_order_total_with_group(1)

        [ @period_qual, @life_qual ].each do |q|
          result = q.met?(order_total.user_id, order_total.pay_period)

          expect(result).to_not be
        end
      end

      it 'returns true when the users downline sales are enough' do
        order_total = create_order_total_with_group(2)

        [ @period_qual, @life_qual ].each do |q|
          result = q.met?(order_total.user_id, order_total.pay_period)

          expect(result).to be
        end
      end

      it 'returns false when the max_leg_percent requirement is not met' do
        order_total = create_order_total_with_group(3, 1)

        result = @max_leg_period_qual.met?(order_total.user_id, order_total.pay_period)

        expect(result).to_not be
      end

      it 'returns true when the max_leg_percent requirement is met' do
        order_total = create_order_total_with_group(2)

        result = @max_leg_period_qual.met?(order_total.user_id, order_total.pay_period)

        expect(result).to be
      end

    end
  end

end
