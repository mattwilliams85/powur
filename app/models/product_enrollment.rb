class ProductEnrollment < ActiveRecord::Base
  belongs_to :product
  belongs_to :user

  validates :product_id,
    presence: true,
    uniqueness: { scope: :user_id }
  validates :user_id, presence: true

  include AASM

  aasm(column: :state) do
    state :enrolled, initial: true
    state :overdue
    state :completed

    event :complete do
      transitions from: [:enrolled, :overdue], to: :completed
    end
  end
end
