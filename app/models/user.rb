class User < ActiveRecord::Base
  include UserSecurity
  include UserInvites
  include NameEmailSearch
  include UserScopes
  include PaperclipScopes

  belongs_to :rank_path

  has_many :quotes
  has_many :customers, through: :quotes
  has_many :orders
  has_many :order_totals
  has_many :rank_achievements
  has_many :bonus_payments
  has_many :overrides, class_name: 'UserOverride'
  has_many :user_activities

  store_accessor :contact, :address, :city, :state, :zip, :phone
  store_accessor :profile, :bio, :twitter_url, :linkedin_url, :facebook_url

  validates_presence_of :email
  validates_presence_of :encrypted_password, on: :create
  validates_presence_of :first_name, :last_name
  validates_presence_of :url_slug, :reset_token, allow_nil: true
  validates_presence_of :phone, :zip
  validates_presence_of :address, :city, :state, allow_nil: true

  after_create :hydrate_upline

  attr_accessor :child_order_totals, :pay_period_rank, :pay_period_quote_count

  before_validation do
    self.lifetime_rank ||= Rank.find_or_create_by_id(1).id
    self.organic_rank ||= 1
    if rank_path_id.nil?
      default = RankPath.where(precedence: 1).first
      self.rank_path_id = default.id if default
    end
  end

  def full_name
    "#{first_name} #{last_name}"
  end

  def create_customer(params)
    customers.create!(params)
  end

  def quote_count_for_pay_period(pay_period)
    User.pay_period_quote_counts(id, pay_period)
  end

  def upline_users
    User.where(id: upline - [id])
  end

  def level
    upline.size
  end

  def downline_users
    User.with_downline_counts.with_parent(id)
  end

  def downline_users_count
    downline_users.count
  end

  def role?(role)
    roles.include?(role.to_s)
  end

  def parent_id
    upline[-2]
  end

  def parent?
    !parent_id.nil?
  end

  def ancestor?(user_id)
    upline.include?(user_id)
  end

  def parent_ids
    upline[0..-2]
  end

  def lifetime_achievements
    @lifetime_achievements ||= rank_achievements
                               .where('pay_period_id is not null')
                               .order(rank_id: :desc, path: :asc).entries
  end

  def make_customer!
    Customer.create!(first_name: first_name, last_name: last_name, email: email)
  end

  def pay_as_rank
    pay_period_rank || organic_rank
  end

  private

  def hydrate_upline # rubocop:disable Metrics/AbcSize
    return if upline && !upline.empty?
    self.upline = sponsor ? sponsor.upline + [ id ] : [ id ]
    User.where(id: id).update_all(upline: upline)
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
