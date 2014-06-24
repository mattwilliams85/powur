class User < ActiveRecord::Base
  include UserSecurity
  include UserInvites
  include NameEmailSearch

  validates :email, email: true, presence: true
  validates_presence_of :encrypted_password, on: :create
  validates_presence_of :first_name, :last_name
  validates_presence_of :url_slug, :reset_token, allow_nil: true
  validate :contact_info_presence

  has_many :quotes
  has_many :customers, through: :quotes

  scope :with_upline_at, ->(id, level){ 
    where('upline[?] = ?', level, id).where('id != ?', id) }
  scope :at_level, ->(rank){ where('array_length(upline, 1) = ?', rank) }

  after_create :set_upline

  def full_name
    "#{first_name} #{last_name}"
  end

  def create_customer(params)
    self.customers.create!(params)
  end

  def upline_users
    User.where(id: self.upline - [self.id])
  end

  def level
    self.upline.size
  end

  def downline_users(down_level = nil)
    query = User.with_upline_at(self.id, self.level)
    query = query.at_level(self.level + down_level) if down_level
    query
  end

  def has_role?(role)
    self.roles.include?(role.to_s)
  end

  private

  def set_upline
    if self.upline.nil? || self.upline.empty?
      self.upline = self.sponsor ? self.sponsor.upline + [self.id] : [self.id]
      User.where(id: self.id).update_all(upline: self.upline)
    end
  end

  CONTACT_FIELDS = { optional: %w(address city state), required_one_of: %w(zip phone) }
  def contact_info_presence
    self.contact.reject! do |key, value|
      !CONTACT_FIELDS.values.any? { |fields| fields.include?(key) }
    end
    result = CONTACT_FIELDS[:required_one_of].any? do |field|
      self.contact[field].present?
    end
    unless result
      CONTACT_FIELDS[:required_one_of].each do |field|
        errors.add(:contact, :presence)
      end
    end
  end

end
