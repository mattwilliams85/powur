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
    value << 'phone' if customer.phone
    value << 'email' if customer.email
    if customer.address && customer.city && customer.state && customer.zip
      value << 'address'
    end
    value << 'utility' if data['kwh']
    value
  end

  def order?
    !order.nil?
  end

  QUOTE_FIELDS = %w(customer_first_name customer_last_name customer_email
                customer_phone customer_address_1 customer_city customer_state
                customer_zip customer_utility customer_average_bill
                customer_rate_schedule customer_square_ft customer_id
                distributor_first_name distributor_last_name distributor_id
                distribor_org)

  private

  def product_data
    invalid_keys = data.keys.select { |key| !product.quote_data.include?(key) }
    errors.add(:data, :invalid_keys) if invalid_keys.size > 0
  end

  class << self
    def to_csv(query)
      query = query.includes(:user, :customer).references(:user, :customer)
      CSV.generate do |csv|
        csv << QUOTE_FIELDS
        query.each do |quote|
          customer = quote.customer
          fields = [ customer.first_name, customer.last_name, customer.email,
                   customer.phone, customer.address, customer.city,
                   customer.state, customer.zip ]

          quote_fields = %w(utility average_bill rate_schedule square_feet)
            .map { |f| quote.data[f] }
          fields.push(*quote_fields)
          fields.push(quote.id)

          user = quote.user
          user_fields = [ user.first_name, user.last_name, user.id, 'Sunstand' ]
          fields.push(*user_fields)

          csv << fields
        end
      end
    end
  end
end
