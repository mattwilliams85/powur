class ProductReceipt < ActiveRecord::Base
  belongs_to :product
  belongs_to :user

  validates :product_id, presence: true
  validates :user_id, presence: true, uniqueness: { scope: :product_id }

  after_create :group_and_rank

  private

  def group_and_rank
    user.group_and_rank!(product_id: product_id)
  end
end
