require 'spec_helper'

describe '/a/ranks/:id/qualifications' do

  before :each do
    login_user
  end

  describe '#index' do

    it 'renders the list of active qualifications' do
      create(:sales_qualification)
      create(:group_sales_qualification)
      create(:sales_qualification, rank: create(:rank))

      get qualifications_path, format: :json

      expect_classes 'qualifications', 'list'
      expect_entities_count(2)
    end

  end

  describe '#create' do

    it 'creates an active qualification' do
      product = create(:product)
      rank_path = create(:rank_path)
      post qualifications_path,
           type:         :sales,
           product_id:   product.id,
           time_period:  :monthly,
           rank_path_id: rank_path.id,
           quantity:     5,
           format:       :json

      expect_classes 'qualification'
    end

  end

  describe '#update' do

    it 'updates a qualification' do
      qualification = create(:group_sales_qualification)

      patch qualification_path(qualification),
            max_leg_percent: 12,
            format:          :json

      max_leg_percent = json_body['properties']['max_leg_percent']

      expect(max_leg_percent).to eq(12)
    end

  end

  describe '#destroy' do

    it 'deletes a qualification' do
      qualification = create(:sales_qualification)

      delete qualification_path(qualification), format: :json

      expect_classes 'qualifications', 'list'
      expect_entities_count(0)
    end
  end

end
