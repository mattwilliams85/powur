class ProductEnrollment < ActiveRecord::Base
  belongs_to :product
  belongs_to :user

  validates :product_id,
    presence: true,
    uniqueness: { scope: :user_id }
  validates :user_id, presence: true

  scope :incomplete, -> { where(state: ['enrolled', 'started']) }

  after_create :start_learner_report_polling

  include AASM

  aasm(column: :state) do
    state :enrolled, initial: true
    state :started
    state :completed
    state :removed

    event :start do
      transitions from: [:enrolled], to: :started
    end

    event :complete do
      transitions from: [:enrolled, :started], to: :completed
      after do
        
      end
    end

    event :remove do
      transitions from: [:enrolled, :started], to: :removed
    end
  end

  def start_learner_report_polling(previous_checks=0)
    new_job = Jobs::UserSmarteruLearnerReportJob.new(user_id, previous_checks)
    Delayed::Job.enqueue(new_job, run_at: 24.hours.from_now)
  end
end
