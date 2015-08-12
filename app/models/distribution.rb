class Distribution < ActiveRecord::Base
  enum status: { pending: 1, paid: 2, cancelled: 3 }

  has_many :pay_periods
  has_many :bonuses
  has_many :bonus_payments

  after_create :set_title

  # Example:
  # distribution.distribute!(
  #   [{ ref_id:   1,
  #      username: 'ewalletusername',
  #      amount:   23.4 }]
  # )
  def distribute!(payments_list)
    client = EwalletClient.new
    load_response = client.ewallet_load(
      batch_id: title,
      payments: payments_list)
    if load_response['m_Text'] == 'OK'
      return update_attributes(distributed_at: Time.zone.now, status: :paid)
    end
    fail(load_response.to_s)
  end

  def cancel
    self.class.transaction do
      bonus_payments.map(&:cancelled!)
      self.cancelled!
    end
  end

  private

  def set_title
    # Used as a batch ID for ewallet load
    update_attribute(:title, 'powur:' + id.to_s)
  end
end
