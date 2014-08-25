class MonthlyPayPeriod < PayPeriod

  has_many :rank_achievements

  def type_display
    'Monthly'
  end

  def calculate!
    OrderTotal.generate_for_pay_period!(self)
    super
  end

  def generate_rank_achievements!
    user_id = user_product_orders.first.user_id
    for i in 0..user_product_orders.size
      product_orders = [ ]
      while user_product_orders[i].user_id == user_id
        product_orders << user_product_orders[i]
        i += 1
      end
      ranks.each do |rank|

      end
    end
  end

  def lifetime_user_product_orders
    @lifetime_user_product_orders ||= begin
      user_ids = user_product_orders.map(&:user_id).uniq
      user_product_grouped.where(user_id: user_ids).before(self.end_date)
    end
  end

  private

  class << self
    def id_from(date)
      date.strftime('%Y-%m')
    end

    def ids_from(date)
      now = DateTime.current
      diff = (now.year * 12 + now.month) - (date.year * 12 + date.month)
      (0...diff).map { |i| id_from(date + i.months) }
    end

    def find_or_create_by_id(id)
      find_or_create_by(id: id) do |period|
        period.start_date = Date.parse("#{id}-01")
        period.end_date = period.start_date.end_of_month
      end
    rescue ActiveRecord::RecordNotUnique
      retry
    end
  end
end
