class Quote < ActiveRecord::Base

  belongs_to :product
  belongs_to :customer
  belongs_to :user
  has_one    :order

  SEARCH = ':q %% %{table}.first_name or :q %% %{table}.last_name or %{table}.email ilike :like'

  scope :search, ->(query, table) {
    where(SEARCH % { table: table }, q: "#{query}", like: "%#{query}%") }
  scope :user_search,     ->(query){ search(query, 'users') }
  scope :customer_search, ->(query){ search(query, 'customers') }
  scope :user_customer_search, ->(query){
    where.any_of(user_search(query), customer_search(query)) }

  validates_presence_of :url_slug, :product_id, :customer_id, :user_id
  validate :product_data

  before_validation do
    self.url_slug ||= SecureRandom.hex(8)
  end

  def can_email?
    self.customer.email && self.user_id && self.user.url_slug
  end

  def email_customer
    PromoterMailer.new_quote(self).deliver if can_email?
  end

  def data_status
    data = []
    data << :phone if self.customer.phone
    data << :email if self.customer.email
    data << :address if self.customer.address && self.customer.city && self.customer.state && self.customer.zip
    data << :utility if self.data['kwh']
    data
  end

  def order?
    !!self.order
  end

  private

  def product_data
    invalid_keys = self.data.keys.select { |key| !self.product.quote_data.include?(key) }
    errors.add(:data, :invalid_keys) if invalid_keys.size > 0
  end

end
