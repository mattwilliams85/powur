class NotificationRelease < ActiveRecord::Base
  belongs_to :user
  belongs_to :notification

  RECIPIENTS = %w(advocates partners)

  validates :user_id, presence: true
  validates :notification_id, presence: true
  validates :recipient,
            inclusion: { in: RECIPIENTS },
            presence:  true

  # Define scopes for RECIPIENTS
  RECIPIENTS.each do |r|
    scope "for_#{r}".to_sym, -> { where(recipient: r) }
  end

  scope :sorted, -> { order(id: :desc) }

  def fetch_recipients
    return [] if recipient.nil? || !RECIPIENTS.include?(recipient)
    scope_name = recipient + '_recipients'
    send(scope_name.to_sym)
  end

  def send_out
    twilio_client = TwilioClient.new
    recipient_numbers = fetch_recipients.map(&:valid_phone).compact
    twilio_client.send_sms_in_groups(recipient_numbers, notification.content)

    update_column(:finished_at, Time.zone.now)
  end

  def advocates_recipients
    User.advocates.can_sms
  end

  def partners_recipients
    User.partners.can_sms
  end
end
