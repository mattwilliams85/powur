class MonthlyPayPeriod < PayPeriod

  has_many :rank_achievements

  def type_display
    'Monthly'
  end

  def calculate!
    super
  end

  # def generate_rank_achievements!
  #   user_product_totals = self.order_totals.entries

  #   users_ids = self.order_totals.map(&:user_id)
  #   user_ids.each do |user_id|

  #   end

  #   user_id = user_product_orders.first.user_id
  #   for i in 0..user_product_orders.size
  #     product_orders = [ ]
  #     while user_product_orders[i].user_id == user_id
  #       product_orders << user_product_orders[i]
  #       i += 1
  #     end
  #     ranks.each do |rank|

  #     end
  #   end
  # end

  private

  def _order_totals_for_user(user_id)
    self.order_totals.find { |t| t.user_id == user_id }
  end

  # def _gen_rank_achievements_for_user(user_id)
  #   product_totals = _order_totals_for_user(user_id)
  #   ranks.each do |rank|
  #     if rank.qualifications.all? { |q| q.met?(user) }
  #   end
  # end

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
