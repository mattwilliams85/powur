require 'spec_helper'

describe EnrollerSalesBonus, type: :model do

  before :each do
    create_list(:rank, 3)
  end

  it '#create_payments!' do
    product = create(:product, bonus_volume: 500, commission_percentage: 80)
    bonus = create(:enroller_sales_bonus)
    create(:bonus_requirement, product: product, bonus: bonus)
    create(:bonus_level, bonus: bonus, amounts: [ 0.0, 0.0 ])
    order = create(:order, product: product)

    bonus.create_payments!(order, order.monthly_pay_period)
  end

end
