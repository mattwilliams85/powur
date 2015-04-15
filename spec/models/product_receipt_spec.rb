require 'spec_helper'

describe ProductReceipt, type: :model do

  describe '#create' do
    let!(:product) { create(:product)}
    let!(:user) { create(:user)}
    let!(:product_receipt) { create(:product_receipt, user_id: user.id, product_id: product.id) }

    it 'validates uniqueness of product_id and user_id' do
      product_receipt = ProductReceipt.create({ user_id: user.id, product_id: product.id })
      expect(product_receipt.errors.messages).to eq({:user_id=>["has already been taken"]})
    end

    it 'creates a product receipt' do
      product_receipt = ProductReceipt.create({ user_id: user.id, product_id: create(:product).id, amount: 100, order_id: 123, transaction_id: 123 })
      expect(product_receipt.errors.messages.length).to eq(0)
    end
  end
end
