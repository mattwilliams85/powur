class Quote < ActiveRecord::Base
  include QuoteSubmission
  belongs_to :product
  belongs_to :customer
  belongs_to :user
  has_one :order

  add_search :user, :customer, [ :user, :customer ]

  scope :not_submitted, ->() { where('submitted_at IS NULL') }
  scope :submitted, ->() { where('submitted_at IS NOT NULL') }

  validates_presence_of :url_slug, :product_id, :customer_id, :user_id
  validate :product_data

  before_validation do
    self.url_slug ||= SecureRandom.hex(8)
  end

  def can_email?
    customer.email && user_id && user.url_slug
  end

  def email_customer
    PromoterMailer.new_quote(self).deliver_later if can_email?
  end

  def data_status
    return 'submitted' if submitted?
    ready_to_submit? ? 'complete' : 'incomplete'
  end

  def order?
    !order.nil?
  end

  private

  def product_data
    invalid_keys = data.keys.select do |key|
      !product.quote_field_keys.include?(key)
    end
    errors.add(:data, :invalid_keys) if invalid_keys.size > 0
  end

  CSV_HEADERS = %w(
    customer_first_name customer_last_name customer_email
    customer_phone customer_address_1 customer_city customer_state
    customer_zip customer_utility customer_average_bill
    customer_roof_type customer_roof_age credit_score_qualified
    customer_square_ft quote_id distributor_first_name
    distributor_last_name distributor_id distribor_org)

  QUOTE_FIELDS = %w(
    utility average_bill roof_type roof_age credit_score_qualified square_feet)

  class << self
    def to_csv(query) # rubocop:disable Metrics/AbcSize
      query = query.includes(:user, :customer).references(:user, :customer)
      quote_fields = Product.default.quote_fields
                     .includes(:lookups).references(:lookups).entries
      quote_fields = QUOTE_FIELDS
                     .map { |name| quote_fields.find { |qf| qf.name == name } }
      required_quote_fields = quote_fields
                              .select(&:required).map(&:name)

      CSV.generate do |csv|
        csv << CSV_HEADERS
        query.each do |quote|
          customer = quote.customer

          next unless customer.complete?
          next if required_quote_fields.any? { |qf| quote.data[qf].nil? }

          fields = [ customer.first_name, customer.last_name, customer.email,
                     customer.phone, customer.address, customer.city,
                     customer.state, customer.zip ]

          quote_field_data = quote_fields.map do |field|
            field.to_csv(quote.data[field.name])
          end
          fields.push(*quote_field_data)
          fields.push(quote.id)

          user = quote.user
          user_fields = [ user.first_name, user.last_name, user.id, 'Powur' ]
          fields.push(*user_fields)

          csv << fields
        end
      end
    end
  end
end
