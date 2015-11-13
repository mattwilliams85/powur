class BonusPayment < ActiveRecord::Base
  enum status: { pending: 1, paid: 2, cancelled: 3, breakage: 4 }

  store_accessor :bonus_data, :lead_number

  belongs_to :pay_period
  belongs_to :bonus
  belongs_to :user
  belongs_to :distribution

  has_many :bonus_payment_leads, dependent: :destroy
  has_many :leads, through: :bonus_payment_leads

  scope :pay_period, ->(id) { where(pay_period: id) }
  scope :with_ewallets, lambda {
    joins(:user).includes(:user)
      .where("exist(users.profile, 'ewallet_username') = true")
      .where("users.profile->'ewallet_username' != ''")
  }
  scope :bonus_totals_by_type, lambda { |pay_period|
    select('sum(amount) AMOUNT, bonus_id')
      .group(:bonus_id)
      .where('pay_period_id = ?', pay_period.id)
  }

  def lead_number
    super && super.to_i
  end
end
