require 'spec_helper'

describe ProductReceipt, type: :model do

  describe '#create' do
    let!(:product) { create(:product) }
    let!(:certification) { create(:product, slug: 'partner') }
    let!(:user) { create(:user) }

    it 'validates uniqueness of product_id and user_id' do
      create(:product_receipt, user_id: user.id, product_id: product.id)
      product_receipt = ProductReceipt.create(
        user_id:      user.id,
        product_id:   product.id,
        purchased_at: Time.zone.now)
      expect(product_receipt.errors.messages).to eq(
        user_id: [ 'has already been taken' ])
    end

    it 'creates a product receipt' do
      product_receipt = ProductReceipt.create(
        user_id:        user.id,
        product_id:     create(:product).id,
        purchased_at:   Time.zone.now,
        amount:         100,
        order_id:       123,
        transaction_id: 123)
      expect(product_receipt.errors.messages.length).to eq(0)
    end

    it 'increases the user\'s available invites by 5 if purchasing certification' do
      expect(user.available_invites).to eq(5)

      ProductReceipt.create(
        user_id:        user.id,
        product_id:     certification.id,
        purchased_at:   Time.zone.now,
        amount:         299,
        order_id:       123,
        transaction_id: 123)

      expect(user.reload.available_invites).to eq(10)
    end
  end
end
