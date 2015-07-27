class Notification < ActiveRecord::Base
  belongs_to :user
  belongs_to :sender, class_name: User

  RECIPIENTS = %w(advocates partners)

  validates :user_id, presence: true
  validates :content, presence: true, length: { maximum: 160 }
  validates :recipient, inclusion: { in: RECIPIENTS }, allow_nil: true

  scope :sorted, -> { order(id: :desc) }
  scope :published, -> { where(is_public: true) }

  # Define scopes for RECIPIENTS
  RECIPIENTS.each { |r| scope "for_#{r}".to_sym, -> { where(recipient: r) } }

  def fetch_recipients
    return [] if recipient.nil? || !RECIPIENTS.include?(recipient)
    scope_name = recipient + '_recipients'
    send(scope_name.to_sym)
  end

  def send_out
    twilio_client = TwilioClient.new
    recipient_numbers = fetch_recipients.map(&:phone).compact
    twilio_client.send_sms_in_groups(recipient_numbers, content)

    update_column(:finished_at, Time.zone.now)
  end

  def as_json(*)
    {
      id:      id,
      content: content
    }
  end

  private

  def advocates_recipients
    # TODO filter out users without phone number and disabled sms notifications
    User.advocates
  end

  def partners_recipients
    # TODO filter out users without phone number and disabled sms notifications
    User.partners
  end
end
