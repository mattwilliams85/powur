require 'spec_helper'

describe '/a/bonuses/:id/requirements' do

  before :each do
    login_user
    @bonus = create(:bonus)
    @product = create(:product)
  end

  describe '#create' do

    it 'adds a requirement' do
      post bonus_requirements_path(@bonus), product_id: @product.id, 
        quantity: 2, source: false, format: :json

      expect_classes 'bonus'
    end

  end

end
