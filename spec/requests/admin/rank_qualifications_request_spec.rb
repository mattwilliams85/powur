require 'spec_helper'

describe '/a/ranks/:id/qualifications' do

  before :each do
    login_user
    @rank = create_list(:rank, 2).last
  end

  describe '#create' do
    def assert_qualification
      expect(json_body['entities'].first['entities'].first['class']).to include('qualification')
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
    it 'updates a group sales qualification' do
      qualification = create(:group_sales_qualification, rank: @rank)

      patch rank_qualification_path(@rank, qualification), 
        max_leg_percent: 12, format: :json

      max_leg_percent = json_body['entities'].
        first['entities'].first['properties']['max_leg_percent']

      expect(max_leg_percent).to eq(12)
    end
  end

  describe '#delete' do
    it 'deletes a qualification from a rank' do
      qualification = create(:sales_qualification, rank: @rank)
      delete rank_qualification_path(@rank, qualification), format: :json

      expect(json_body['entities'].first['entities'].size).to eq(0)
    end
  end

end