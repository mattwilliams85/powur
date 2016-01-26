class Product < ActiveRecord::Base
  after_create :assign_sku

  belongs_to :prerequisite, class_name: 'Product'

  has_many :bonuses
  has_many :quote_fields, dependent: :destroy
  has_many :quote_field_lookups, through: :quote_fields
  has_many :product_receipts
  has_many :product_enrollments, dependent: :destroy

  validates_presence_of :name, :bonus_volume, :commission_percentage
  validates :commission_percentage, numericality: { less_than_or_equal_to: 100 }

  scope :with_bonuses, -> { includes(bonuses: [ :bonus_amounts ]) }
  scope :university_classes, -> { where(is_university_class: true) }
  scope :free, -> { where(bonus_volume: 0) }
  scope :sorted, -> { order(position: :asc) }

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

  def purchased_by?(user)
    product_receipts.where(user_id: (user.try(:id) || user)).exists?
  end

  def completed_by?(user)
    product_enrollments
      .where(user_id: (user.try(:id) || user)).completed.exists?
  end

  def free?
    bonus_volume == 0
  end

  def prerequisites_taken?(user)
    return true if prerequisite.nil?
    enrollment = user.product_enrollments.where(
      product_id: prerequisite_id).first
    !enrollment.nil? && enrollment.completed?
  end

  def purchase(form, user)
    nmi_gateway = NmiGateway.new(form)
    response = nmi_gateway.do_post

    return false if response['response_code'].first != '100'

    user.zip = form[:zip] unless user.zip
    user.save

    product_receipts.create(
      user_id:        user.id,
      amount:         form[:amount],
      transaction_id: response['transactionid'].first,
      auth_code:      response['authcode'].first,
      purchased_at:   Time.zone.now)
  end

  def complimentary_purchase(user)
    product_receipts.create(
      user_id:        user.id,
      amount:         0,
      transaction_id: 'Complimentary',
      auth_code:      'Complimentary',
      purchased_at:   Time.zone.now)
  end

  def deletable?
    !(product_receipts.any? || product_enrollments.any? || quote_fields.any?)
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
