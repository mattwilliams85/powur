class Notification < ActiveRecord::Base
  belongs_to :user
  belongs_to :sender, class_name: User

  RECIPIENTS = %w(advocates partners)

  validates :user_id, presence: true
  validates :content, presence: true, length: { maximum: 160 }
  validates :recipient, inclusion: { in: RECIPIENTS }, allow_nil: true

  def fetch_recipients
    return [] if recipient.nil? || !RECIPIENTS.include?(recipient)
    scope_name = recipient + '_recipients'
    send(scope_name.to_sym)
  end

  def send_out
    fetch_recipients.each do |user|
      begin
        user.send_sms(user.phone, content)
      rescue => e
        Airbrake.notify(e)
      end
    end
    update_column(:finished_at, Time.zone.now)
  end

  private

  def advocates_recipients
    User.advocates
  end

  def partners_recipients
    User.partners
  end
end
