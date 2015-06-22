class ProductEnrollment < ActiveRecord::Base
  include EwalletDSL

  belongs_to :product
  belongs_to :user

  validates :product_id,
            presence:   true,
            uniqueness: { scope: :user_id }
  validates :user_id, presence: true

  scope :incomplete, -> { where("state != 'completed'") }
  scope :user_product, lambda { |user_id, product_id|
    where(user_id: user_id, product_id: product_id)
  }
  # TODO: use max class due date to figure out the cut off date,
  # so we don't keep polling abandoned enrollments forever
  scope :need_status_refresh, lambda {
    includes(:product, :user).joins(:product, :user).incomplete
  }

  include AASM

  aasm(column: :state) do
    state :enrolled, initial: true
    state :started
    state :completed

    event :start do
      transitions from: [:enrolled], to: :started
    end

    event :complete do
      transitions from: [:enrolled, :started], to: :completed
      after do
        # TODO: ipayout account creation should be moved elsewhere
        # Create IPayout account if user passed required class (FIT)
        # find_or_create_ipayout_account(user) if product.is_required_class
        UserUserGroup.populate_for_user_product(user_id, product_id)
        user.rank_up! if user.needs_rank_up?
      end
    end
  end

  def refresh_enrollment_status
    report = user.smarteru.enrollment(product)
    return unless report

    if report[:completed_date]
      complete! unless completed?
    elsif report[:started_date]
      start! unless started?
    end
  end
end
