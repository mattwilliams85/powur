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

  def pp_json
    @orders_json ||= PayPeriodsJson.new(self, @pay_periods, @pay_period)
  end

  def bonus_json
    @bonus_json ||= BonusJson.new(self, @bonuses, @bonus)
  end

  def earnings_json
    @earnings_json ||= EarningsJson.new(self, @earnings, @earning)
  end

  def social_media_posts_json
    @social_media_posts_json ||= SocialMediaPostsJson.new(self, @social_media_posts, @social_media_posts)
  end

  def invites_json
    @invites_json ||= InvitesJson.new(self, @invites, @invite)
  end
end
