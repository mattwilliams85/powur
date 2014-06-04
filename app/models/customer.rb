class Customer < ActiveRecord::Base

  enum status: [ :pending, :complete, :submitted, :scheduled, :completed, :rejected ]

  belongs_to :promoter, class_name: 'User'

  validates_presence_of :url_slug, :first_name, :last_name, :promoter_id

  before_validation do
    self.url_slug ||= SecureRandom.hex(8)
  end

  def full_name
    "#{self.first_name} #{self.last_name}"
  end

end