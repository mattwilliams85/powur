require 'spec_helper'

describe '/a/products' do

  before :each do
    login_user
    @rank = create(:rank)
  end

  describe '#create' do
    def assert_qualification
      expect(json_body['entities'].first['entities'].first['class']).to include('qualification')
    end

    it 'creates a certification qualification' do
      post rank_qualifications_path(@rank), 
        type: :certification, name: 'Jedi Training', format: :json

      assert_qualification
    end

    it 'creates a sales qualification' do
      product = create(:product)
      post rank_qualifications_path(@rank),
        type: :sales, product_id: product.id, period: :pay_period, quantity: 5, format: :json

      assert_qualification
    end

    it 'creates a group sales qualification' do
      product = create(:product)

      post rank_qualifications_path(@rank),
        type: :group_sales, product_id: product.id, period: :lifetime, 
        quantity: 5, max_leg_percent: 55, format: :json

      assert_qualification
    end
  end

  describe '#update' do
  end

  describe '#delete' do
    it 'deletes a qualification from a rank' do
      qualification = create(:certification_qualification, rank: @rank)
      delete rank_qualification_path(@rank, qualification), format: :json

      expect(json_body['entities'].first['entities'].size).to eq(0)
    end
  end

end