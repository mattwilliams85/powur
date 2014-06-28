class User < ActiveRecord::Base
  include UserSecurity
  include UserInvites
  include NameEmailSearch

  validates :email, email: true, presence: true
  validates_presence_of :encrypted_password, on: :create
  validates_presence_of :first_name, :last_name
  validates_presence_of :url_slug, :reset_token, allow_nil: true
  store_accessor :contact, :address, :city, :state, :zip, :phone
  validates_presence_of :phone, :zip
  validates_presence_of :address, :city, :state, allow_nil: true

  has_many :quotes
  has_many :customers, through: :quotes

  scope :with_upline_at, ->(id, level){ 
    where('upline[?] = ?', level, id).where('id != ?', id) }
  scope :at_level, ->(rank){ where('array_length(upline, 1) = ?', rank) }
  CHILD_COUNT_LIST = "
    select u.*, child_count - 1 downline_count
      from (
      select unnest(upline) parent_id, count(id) child_count
      from users
      group by parent_id
    ) c inner join users u on c.parent_id = u.id
    where u.upline[?] = ? and array_length(u.upline, 1) = ?
    order by u.last_name, u.first_name, u.id;"
  scope :child_count_list, ->(user) {
    find_by_sql([ CHILD_COUNT_LIST, user.level, user.id, user.level + 1 ]) }

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

  def downline_users(down_level = 1)
    User.child_count_list(self)
  end
  # def downline_users(down_level = nil)
  #   query = User.with_upline_at(self.id, self.level)
  #   query = query.at_level(self.level + down_level) if down_level
  #   query
  # end

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

end
