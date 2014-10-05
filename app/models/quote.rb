class Quote < ActiveRecord::Base
  belongs_to :product
  belongs_to :customer
  belongs_to :user
  has_one :order

  add_search :user, :customer, [ :user, :customer ]

  validates_presence_of :url_slug, :product_id, :customer_id, :user_id
  validate :product_data

  before_validation do
    self.url_slug ||= SecureRandom.hex(8)
  end

  def can_email?
    customer.email && user_id && user.url_slug
  end

  def email_customer
    PromoterMailer.new_quote(self).deliver if can_email?
  end

  def data_status
    value = []
    value << :phone if customer.phone
    value << :email if customer.email
    if customer.address && customer.city && customer.state && customer.zip
      value << :address
    end
    value << :utility if data['kwh']
    value
  end

  def order?
    !order.nil?
  end

  private

  def product_data
    invalid_keys = data.keys.select { |key| !product.quote_data.include?(key) }
    errors.add(:data, :invalid_keys) if invalid_keys.size > 0
  end
end
