module ApplicationHelper
  def ranks_json
    @ranks_json ||= RanksJson.new(self, @ranks, @rank)
  end

  def users_json
    @users_json ||= UsersJson.new(self, @users, @user)
  end

  def quotes_json
    @quotes_json ||= QuotesJson.new(self, @quotes, @quote)
  end

  def qual_json
    @qual_json ||= QualificationsJson.new(self, @qualifications, @qualification)
  end

  def orders_json
    @orders_json ||= OrdersJson.new(self, @orders, @order)
  end

  def totals_json
    @totals_json ||= OrderTotalsJson.new(self, @order_totals, nil)
  end

  def profile_json
    @orders_json ||= ProfileJson.new(self, @profile, @user)
  end
end
