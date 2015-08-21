class Distribution < ActiveRecord::Base
  enum status: { pending: 1, paid: 2, cancelled: 3 }

  has_many :pay_periods
  has_many :bonuses
  has_many :bonus_payments

  after_create :set_batch_id

  def ewallet_client
    @ewallet_client ||= EwalletClient.new
  end

  def distribute_pay_period!(pay_period)
    payments = pay_period.bonus_payments.pending.entries
    payment_ids = payments.map(&:id)

    BonusPayment.where(id: payment_ids).update_all(
      distribution_id: id)

    distribute!(payments)
  end

  def distribute!(payments)
    batches = prepare_for_distribution(payments)
    successful_payment_ids = []
    batches.each do |user_id, data|
      if process_payment(user_id, data[:distribution_data])
        successful_payment_ids.concat(data[:payment_ids])
      end
    end
    BonusPayment.where(id: successful_payment_ids).update_all(
      status: BonusPayment.statuses['paid'])

    update_attributes(distributed_at: Time.zone.now, status: :paid)
  end

  # Input: array of BonusPayment instances
  # Output: {
  #   1: {
  #     payment_ids: [1,2,3],
  #     distribution_data: {
  #       ref_id:   1,
  #       username: 'ewalletusername',
  #       amount:   2.3
  #     }
  #   }
  # }
  def prepare_for_distribution(payments)
    batches = {}
    payments.each do |payment|
      if payment.user.breakage_account?
        payment.breakage!
        next
      end

      begin
        payment.user.ewallet! unless payment.user.ewallet?
      rescue => e
        Airbrake.notify(e)
        next # Tear drop. We tried
      end

      batch = batches[payment.user_id] || batch_for(payment)
      batch[:payment_ids].push(payment.id)
      batch[:distribution_data][:amount] += payment.amount
      batches[payment.user_id] = batch
    end

    batches
  end

  def batch_for(payment)
    { payment_ids:       [],
      distribution_data: {
        ref_id:   payment.user_id,
        username: payment.user.ewallet_username,
        amount:   0 } }
  end

  def process_payment(user_id, distribution_data)
    ewallet_client.ewallet_individual_load(
      batch_id: batch_id,
      payment:  distribution_data)
  rescue Ipayout::Error::EwalletNotFound => e
    User.find_by_id(user_id).update_attribute(:ewallet_username, nil)
    Airbrake.notify(e)
    return nil
  end

  def cancel
    self.class.transaction do
      bonus_payments.map(&:cancelled!)
      self.cancelled!
    end
  end

  private

  def set_batch_id
    update_attribute(:batch_id, 'powur:' + batch_id.to_s + id.to_s)
  end
end
