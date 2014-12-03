class UserActivity < ActiveRecord::Base
  enum event: { login: 'login', invite: 'invite' }

  belongs_to :user

  scope :before,
        ->(event_time) { where('event_time < ?', event_time.to_date) }
  scope :after,
        ->(event_time) { where('event_time >= ?', event_time.to_date) }
  scope :by_pay_period,
        ->(period) { before(period.end_date + 1.day).after(period.start_date) }

  scope :for_user_by_pay_period, ->(pay_period, user) {
    where('user_id = ?', user.id)
      .before(pay_period.end_date + 1.day)
      .after(pay_period.start_date)
  }
end
