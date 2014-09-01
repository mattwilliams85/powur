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
  has_many :orders
  has_many :order_totals
  has_many :rank_achievements
  has_many :onetime_rank_achievements

  scope :with_upline_at, ->(id, level){ 
    where('upline[?] = ?', level, id).where('id != ?', id) }
  scope :at_level, ->(rank){ where('array_length(upline, 1) = ?', rank) }
  CHILD_COUNT_LIST = "
    SELECT u.*, child_count - 1 downline_count
    FROM (
      SELECT unnest(upline) parent_id, count(id) child_count
      FROM users
      GROUP BY parent_id) c INNER JOIN users u ON c.parent_id = u.id
    WHERE u.upline[?] = ? AND array_length(u.upline, 1) = ?
    ORDER BY u.last_name, u.first_name, u.id;"
  scope :child_count_list, ->(user){
    find_by_sql([ CHILD_COUNT_LIST, user.level, user.id, user.level + 1 ]) }
  scope :with_parent, ->(*user_ids){
    where('upline[array_length(upline, 1) - 1] IN (?)', user_ids.flatten) }

  before_validation do
    self.lifetime_rank ||= Rank.find_or_create_by_id(1)
  end

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

  def downline_users
    User.child_count_list(self)
  end

  def has_role?(role)
    self.roles.include?(role.to_s)
  end

  def parent_id
    self.upline[-2]
  end

  def make_customer!
    Customer.create!(first_name: first_name, last_name: last_name, email: email)
  end

  private

  def set_upline
    if self.upline.nil? || self.upline.empty?
      self.upline = self.sponsor ? self.sponsor.upline + [self.id] : [self.id]
      User.where(id: self.id).update_all(upline: self.upline)
    end
  end

  class << self
    UPDATE_LIFETIME_RANKS = "
      UPDATE users
      SET lifetime_rank = ra.rank_id
      FROM (
        SELECT user_id, max(rank_id) rank_id
        FROM rank_achievements
        WHERE pay_period_id = ?
        GROUP BY user_id) ra
      WHERE users.id = ra.user_id AND 
        (ra.rank_id > users.lifetime_rank OR users.lifetime_rank IS NULL)"

    def update_lifetime_ranks(pay_period_id)
      sql = sanitize_sql([ UPDATE_LIFETIME_RANKS, pay_period_id ])
      connection.execute(sql)
    end
  end

end
