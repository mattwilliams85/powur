class Distribution < ActiveRecord::Base
  enum status: { pending: 1, paid: 2, cancelled: 3 }

  has_many :pay_periods
  has_many :bonuses
  has_many :bonus_payments

  after_create :set_title

  def distribute!(payments)
    client = EwalletClient.new

    successful_payment_ids = []
    payments.each do |payment|
      begin
        client.ewallet_individual_load(
          batch_id: title,
          payment:  payment.distribution_data)
        successful_payment_ids.push(payment.id)
      rescue Ipayout::Error::EwalletNotFound => e
        payment.user.update_attribute(:ewallet_username, nil)
        Airbrake.notify(e)
      end
    end
    BonusPayment.where(id: successful_payment_ids).update_all(
      status: BonusPayment.statuses['paid'])

    update_attributes(distributed_at: Time.zone.now, status: :paid)
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
