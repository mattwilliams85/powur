class Customer < ActiveRecord::Base

  enum status: [ :incomplete, :complete, :submitted, :accepted, :rejected, :installed ]

  belongs_to :promoter, class_name: 'User'

  validates_presence_of :url_slug, :first_name, :last_name, :promoter_id

  before_validation do
    self.url_slug ||= SecureRandom.hex(8)
  end

  SEARCH_FIELDS = %w(first_name last_name email address city)
  SEARCH = SEARCH_FIELDS.map { |f| "#{f} ilike :q" }.join(' ')
  scope :search, ->(query){ where(SEARCH, q: "%#{query}%") }

  def full_name
    "#{self.first_name} #{self.last_name}"
  end

end