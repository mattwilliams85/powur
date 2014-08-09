class Order < ActiveRecord::Base

  enum status: { pending: 1, shipped: 2, cancelled: 3, refunded: 4 }

  belongs_to :bonus_plan
  belongs_to :product
  belongs_to :user
  belongs_to :customer
  belongs_to :quote

  SEARCH = ':q %% %{table}.first_name or :q %% %{table}.last_name or %{table}.email ilike :like'

  scope :search, ->(query, table) {
    where(SEARCH % { table: table }, q: "#{query}", like: "%#{query}%") }
  scope :user_search,     ->(query){ search(query, 'users') }
  scope :customer_search, ->(query){ search(query, 'customers') }
  scope :user_customer_search, ->(query){
    where.any_of(user_search(query), customer_search(query)) }
  
end
