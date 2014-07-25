require 'spec_helper'

describe '/a/bonuses/:id/requirements' do

  before :each do
    login_user
    @bonus = create(:direct_sales_bonus)
    @product = create(:product)
  end

  describe '#create' do

    it 'adds a requirement' do
      post bonus_requirements_path(@bonus), product_id: @product.id, 
        quantity: 2, format: :json

      expect_classes 'bonus'
    end

  end

  describe '#update' do

    it 'updates a requirement' do
      requirement = create(:bonus_requirement, bonus: @bonus)

      patch bonus_requirement_path(@bonus, requirement.product_id), quantity: 22, format: :json

      req_list = json_body['entities'].find { |e| e['class'].include?('requirements') }
      result = req_list['entities'].first['properties']['quantity']

      expect(result).to eq(22)
    end

  end

  describe '#destroy' do

    it 'deletes a requirement' do
      requirement = create(:bonus_requirement, bonus: @bonus)

      delete bonus_requirement_path(@bonus, requirement.product_id), format: :json

      expect_classes 'bonus'
      list = json_body['entities'].find { |e| e['class'].include?('requirements') }
      expect(list['entities'].size).to eq(0)
    end

  end

end