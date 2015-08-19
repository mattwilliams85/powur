class BonusPayment < ActiveRecord::Base
  enum status: { pending: 1, paid: 2, cancelled: 3, breakage: 4 }

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
  scope :for_pay_period, lambda {
    joins(:bonus).where('bonuses.schedule <> 3')
  }

  # scope :for_user, ->(id) { where(user_id: id.to_i) }
  # scope :bonus, ->(id) { where(bonus_id: id.to_i) }
  # scope :before, ->(date) { where('created_at < ?', date.to_date) }
  # scope :after, ->(date) { where('created_at >= ?', date.to_date) }

  # scope :user_bonus_totals, lambda { |period|
  #                             select('user_id, sum(amount) AMOUNT')
  #                               .pay_period(period)
  #                               .group(:user_id)
  #                               .order(:user_id)
  #                           }

  # scope :user_bonus_summary, lambda { |user_id, pay_periods|
  #                              select('sum(amount) AMOUNT, pay_period_id')
  #                                .for_user(user_id)
  #                                .group(:pay_period_id)
  #                                .where('pay_period_id IN(?)', pay_periods.ids)
  #                            }
  # scope :bonus_totals_by_type, lambda { |pay_period|
  #                               select('sum(amount) AMOUNT, bonus_id')
  #                                 .group(:bonus_id)
  #                                 .where('pay_period_id = ?', pay_period.id)
  #                             }
  # # scope orders for bonus payment
  # scope :bonus_sums, lambda {
  #   select('bonus_id, sum(amount) amount, count(id) quantity')
  #     .includes(:bonus).group(:bonus_id)
  # }
end
