class DistributePayPeriodJob < ActiveJob::Base
  queue_as :default

  before_enqueue do |job|
    PayPeriod.disbursable.where(id: job.arguments.first)
      .update_all(status: PayPeriod.statuses[:queued])
  end

  def perform(id)
    result = PayPeriod.queued.where(id: id)
      .update_all(status: PayPeriod.statuses[:distributing])
    return unless result == 1

    pay_period = PayPeriod.find(id)
    pay_period.distribute!
  end
end
