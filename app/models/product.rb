class Product < ActiveRecord::Base
  after_create :assign_sku

  has_many :qualifications, dependent: :destroy
  has_many :bonuses
  has_many :quote_fields, dependent: :destroy
  has_many :quote_field_lookups, through: :quote_fields
  has_many :product_receipts
  has_many :product_enrollments, dependent: :destroy
  has_many :user_group_requirements, dependent: :destroy

  validates_presence_of :name, :bonus_volume, :commission_percentage
  validates :commission_percentage, numericality: { less_than_or_equal_to: 100 }

  scope :with_bonuses, -> { includes(bonuses: [ :bonus_amounts ]) }
  scope :certifiable, -> { where(certifiable: true) }
  scope :free, -> { where(bonus_volume: 0) }
  scope :sorted, -> { order('position ASC') }

  def sale_bonuses
    @sale_bonuses ||= bonuses.select { |b| b.sale? && b.enabled? }
  end

  def pay_period_end_bonuses
    @pay_period_end ||= bonuses.select { |b| b.pay_period_end? && b.enabled? }
  end

  def sales_bonuses?
    !sales_bonuses.empty?
  end

  def commission_amount
    bonus_volume * (0.01 * commission_percentage)
  end

  def commission_used
    @commission_used ||= bonuses.map(&:amount_used).inject(:+)
  end

  def commission_remaining(bonus = nil)
    value = commission_amount - commission_used
    value += bonus.amount_used if bonus
    value
  end

  def quote_field_keys
    @quote_field_keys ||= quote_fields.map(&:name)
  end

  def assign_sku
    self.sku = id.to_s.rjust(7, '0')
    save!
  end

  def purchased_by?(user_id)
    product_receipts.where(user_id: user_id).exists?
  end

  def completed_by?(user_id)
    product_enrollments.where(user_id: user_id).completed.exists?
  end

  def is_free?
    bonus_volume == 0
  end

  def purchase(form, user)
    nmi_gateway = NmiGateway.new(form)
    response = nmi_gateway.do_post

    return false if response['response_code'].first != '100'

    user.address = form[:address1] unless user.address
    user.city = form[:city] unless user.city
    user.state = form[:state] unless user.state
    user.zip = form[:zip] unless user.zip
    user.phone = form[:phone] unless user.phone
    user.save

    product_receipts.create(
      user_id:        user.id,
      amount:         form[:amount] * 100,
      transaction_id: response['transactionid'].first,
      auth_code:      response['authcode'].first,
      order_id:       response['orderid'].first
    )
  end

  class << self
    def default_id
      SystemSettings.default_product_id
    end

    def default
      Product.find(default_id)
    rescue ActiveRecord::RecordNotFound
      if Product.any?
        product = Product.first
        SystemSettings.default_product_id = Product.first.id
      else
        product = false
      end
      product
    end
  end
end
