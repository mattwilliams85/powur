require 'spec_helper'

describe '/a/products' do

  before :each do
    login_user
    @product = create(:product)
  end

  describe '#create' do
    it 'creates a certification qualification' do
      # post rank_qualifications_path(@product), 
      #   type: :certification, name: 'Jedi Training'


    end
  end

  describe '#update' do
  end

  describe '#delete' do
  end

end