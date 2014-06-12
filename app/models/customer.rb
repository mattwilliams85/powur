class Customer < ActiveRecord::Base
  include NameEmailSearch
  after_create :email_customer

  enum status: [ :incomplete, :complete, :submitted, :accepted, :voided, :installed ]

  belongs_to :promoter, class_name: 'User'

  validates :url_slug, :first_name, :last_name, :promoter_id, :status, presence: true
  validates :email, :phone, :address, :city, :state, :zip, presence: true, allow_nil: true

  before_validation do
    self.url_slug ||= SecureRandom.hex(8)
  end

  def full_name
    "#{self.first_name} #{self.last_name}"
  end

  def data_status
    data = []
    data << :phone if self.phone
    data << :email if self.email
    data << :address if self.address && self.city && self.state && self.zip
    data << :utility if self.kwh
    data
  end

  private

  def can_email?
    self.email && self.promoter_id && self.promoter.url_slug
  end

  def email_customer
    PromoterMailer.customer_onboard(self).deliver if can_email?
  end

end