class Quote < ActiveRecord::Base

  belongs_to :product
  belongs_to :customer
  belongs_to :user

  SEARCH = ':q % customers.first_name or :q % customers.last_name or customers.email ilike :like'

  scope :customer_search, ->(query){ where(SEARCH, q: "#{query}", like: "%#{query}%") }

  validates_presence_of :url_slug, :product_id, :customer_id, :user_id
  validate :product_data

  before_validation do
    self.url_slug ||= SecureRandom.hex(8)
  end

  def can_email?
    self.customer.email && self.sponsor_id && self.sponsor.url_slug
  end

  def email_customer
    PromoterMailer.customer_onboard(self).deliver if can_email?
  end

  private

  def product_data
    invalid_keys = self.data.keys.select { |key| !self.product.quote_data.include?(key) }
    errors.add(:data, :invalid_keys) if invalid_keys.size > 0
  end

end
