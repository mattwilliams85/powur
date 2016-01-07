class ProductReceipt < ActiveRecord::Base
  belongs_to :product
  belongs_to :user

  validates :product_id, presence: true
  validates :user_id, presence: true, uniqueness: { scope: :product_id }
  validates :purchased_at, presence: true

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
  scope :by_team, lambda { |user_id|
    joins(:user).merge(User.with_ancestor(user_id)).references(:user)
  }
  scope :purchased_at, lambda { |from: nil, to: nil|
    query = current_scope
    query = query.where('purchased_at >= ?', from) if from
    query = query.where('purchased_at <= ?', to) if to
    query
  }
end
