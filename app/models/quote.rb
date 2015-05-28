class Quote < ActiveRecord::Base
  include QuoteSubmission
  belongs_to :product
  belongs_to :customer
  belongs_to :user
  has_many :lead_updates
  has_one :order

  enum status: [ 
    :incomplete, :ready_to_submit, :ineligible_location,
    :submitted, :in_progress, :closed_won, :lost, :on_hold ]

  add_search :user, :customer, [ :user, :customer ]

  scope :not_submitted, ->() { where.not(status: statuses[:submitted]) }
  scope :status, ->(value) { where(status: statuses[value]) }
  scope :won, ->() { status(:closed_won) }
  scope :within_date_range, ->(begin_date , end_date) {
    where("created_at between ? and ?", begin_date, end_date)
  }
  scope :user_product, ->(user_id, product_id) {
    where(user_id: user.id, product_id: product_id)
  }

  validates_presence_of :url_slug, :product_id, :customer_id, :user_id
  validate :product_data

  before_validation do
    self.url_slug ||= SecureRandom.hex(8)
    calculate_status
  end

  def can_email?
    customer.email && user_id && user.url_slug && zip_code_valid?
  end

  def email_customer
    PromoterMailer.new_quote(self).deliver_later if can_email?
  end

  def order?
    !order.nil?
  end

  def submitted?
    !provider_uid.nil?
  end

  def last_update
    @last_update ||= lead_updates.order(updated_at: :desc).first
  end

  def calculated_status
    if submitted?
      return last_update ? last_update.quote_status : :submitted
    end
    return :ineligible_location if !zip_code_valid?
    can_submit? ? :ready_to_submit : :incomplete
  end

  def calculate_status
    self.status = calculated_status
  end

  private

  def product_data
    invalid_keys = data.keys.select do |key|
      !product.quote_field_keys.include?(key)
    end
    errors.add(:data, :invalid_keys) if invalid_keys.size > 0
  end

  class << self
    def won_totals(user, product, pay_period)
      personal_lifetime = won.user_product(user.id, product.id).count
    end

    def find_by_external_id(external_id)
      prefix, quote_id = external_id.split(':')
      return nil unless prefix == QuoteSubmission.id_prefix
      Quote.find(quote_id.to_i)
    end
  end
end
