class ProductEnrollment < ActiveRecord::Base
  include EwalletDSL

  belongs_to :product
  belongs_to :user

  validates :product_id,
    presence:   true,
    uniqueness: { scope: :user_id }
  validates :user_id, presence: true

  scope :incomplete, -> { where("state != 'completed'") }
  scope :user_product, ->(user_id, product_id) {
    where(user_id: user_id, product_id: product_id)
  }

  after_create :start_learner_report_polling

  include AASM

  aasm(column: :state) do
    state :enrolled, initial: true
    state :started
    state :completed
    state :removed

    event :reenroll do
      transitions from: [:removed], to: :enrolled
      after do
        # start polling again
        start_learner_report_polling
      end
    end

    event :start do
      transitions from: [:enrolled], to: :started
    end

    event :complete do
      transitions from: [:enrolled, :started], to: :completed
      after do
        # Create IPayout account if user passed required class (FIT)
        find_or_create_ipayout_account(user) if product.is_required_class
        UserUserGroup.populate_for_user_product(user_id, product_id)
        user.rank_up! if user.needs_rank_up?
      end
    end

    event :remove do
      transitions from: [:enrolled, :started], to: :removed
    end
  end

  def start_learner_report_polling
    new_job = Jobs::UserSmarteruLearnerReportJob.new(user_id, 0)
    Delayed::Job.enqueue(
      new_job,
      run_at: 30.minutes.from_now
    )
  end
end
