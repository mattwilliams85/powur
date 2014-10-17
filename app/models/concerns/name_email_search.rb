module NameEmailSearch
  extend ActiveSupport::Concern

  SEARCH = ':q % first_name or :q % last_name or email ilike :like'

  included do
    scope :search, ->(q) { where(SEARCH, q: "#{q}", like: "%#{q}%") }
  end
end
