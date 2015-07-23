module NameEmailSearch
  extend ActiveSupport::Concern

  SEARCH = ':q % first_name or :q % last_name or email ilike :like'

  included do
    scope :search, lambda { |q|
      if (qi = q.to_i) && qi.to_s == q
        where(id: qi)
      else
        where(SEARCH, q: "#{q}", like: "%#{q}%")
      end
    }
  end
end
