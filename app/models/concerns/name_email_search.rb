module NameEmailSearch
  extend ActiveSupport::Concern

  def name_and_email
    "\"#{full_name}\" <#{email}>"
  end

  # SEARCH = ':q % %{t}.first_name or :q % %{t}.last_name or %{t}.email ilike :like'

  included do
    scope :search, lambda { |q|
      if (qi = q.to_i) && qi.to_s == q
        where(id: qi)
      else
        sql = ":q % #{table_name}.first_name
          OR :q % #{table_name}.last_name
          OR #{table_name}.email ILIKE :like"
        where(sql, q: "#{q}", like: "%#{q}%")
      end
    }
  end
end
