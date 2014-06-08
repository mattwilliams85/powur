class Customer < ActiveRecord::Base
  include NameEmailSearch

  enum status: [ :incomplete, :complete, :submitted, :accepted, :rejected, :installed ]

  belongs_to :promoter, class_name: 'User'

  validates_presence_of :url_slug, :first_name, :last_name, :promoter_id

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

end