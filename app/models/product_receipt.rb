class ProductReceipt < ActiveRecord::Base
  belongs_to :product
  belongs_to :user

  validates :product_id, presence: true
  validates :user_id, presence: true, uniqueness: { scope: :product_id }
  validates :purchased_at, presence: true

  after_create :award_invites

  scope :partner, -> { joins(:product).where(products: { slug: 'partner' }) }
  scope :exclude_users, lambda { |query|
    joins("LEFT JOIN (#{query.to_sql}) eu
          ON product_receipts.user_id = eu.user_id")
      .where('eu.user_id IS NULL')
  }
  scope :include_users, lambda { |query|
    joins("INNER JOIN (#{query.to_sql}) iu
          ON product_receipts.user_id = iu.user_id")
  }

  private

  def award_invites
    return unless product.slug == 'partner'
    user.update_column(
      :available_invites,
      user.available_invites + 10)
  end
end
