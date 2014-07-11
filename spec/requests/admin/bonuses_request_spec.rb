require 'spec_helper'

describe '/a/bonuses' do

  before :each do
    login_user
    @product = create(:product)
  end

  describe '#index' do

    it 'returns a list of bonuses' do
    end


  end

  describe '#create' do

    it 'creates a direct sales bonus' do
      # post bonuses_path, 
      #   type:       :direct_sales, 
      #   amounts:    [150, 200, 200],
      #   product_id: @product.id,
      #   period:     :weekly,
      #   format:     :json

    end

  end
end