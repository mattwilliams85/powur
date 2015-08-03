class User < ActiveRecord::Base
  include UserSecurity
  include UserInvites
  include NameEmailSearch
  include UserScopes
  include PaperclipScopes
  include Phone
  include UserMailchimp

  belongs_to :rank_path

  has_many :leads
  has_many :customers, through: :leads
  has_many :orders
  has_many :order_totals
  has_many :rank_achievements
  has_many :bonus_payments
  has_many :overrides, class_name: 'UserOverride'
  has_many :user_activities
  has_many :product_receipts
  has_many :product_enrollments, dependent: :destroy
  has_many :user_user_groups, dependent: :destroy
  has_many :user_groups, through: :user_user_groups

  store_accessor :contact,
                 :address, :city, :state, :country, :zip, :phone
  store_accessor :profile,
                 :bio, :twitter_url, :linkedin_url, :facebook_url,
                 :communications, :watched_intro, :tos_version,
                 :allow_sms, :allow_system_emails, :allow_corp_emails,
                 :notifications_read_at

  # No extra email validation needed,
  # email validation and confirmation happens with Invite
  # PW: update happens in profile edit correct?
  EMAIL_UNIQUE = { message: 'This email is taken', case_sensitive: false }
  validates :email,
            uniqueness: EMAIL_UNIQUE,
            presence:   true
  validates :encrypted_password, presence: true, on: :create
  validates :first_name, presence: true
  validates :last_name, presence: true
  PASSWORD_LENGTH = {
    minimum: 8,
    maximum: 40,
    message: 'Password must be at least 8 characters.' }
  validates :password,
            presence:     true,
            length:       PASSWORD_LENGTH,
            confirmation: true,
            on:           :create
  validates :password_confirmation, presence: true, on: :create
  validates_presence_of :url_slug, :reset_token, allow_nil: true
  validates :available_invites, numericality: { greater_than_or_equal_to: 0 }

  before_create :set_url_slug
  after_create :hydrate_upline

  attr_reader :password
  attr_accessor :child_order_totals, :pay_period_rank, :password_confirmation

  def full_name
    "#{first_name} #{last_name}"
  end

  def create_customer(params)
    customers.create!(params)
  end

  def upline_users
    User.where(id: upline - [id])
  end

  def level
    upline.size
  end

  def downline_users
    User.with_parent(id)
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

  def moveable_by?(user)
    return true if user.role?(:admin)
    sponsor_id == user.id && DateTime.current <= created_at + 60.days
  end

  def eligible_parents(user = nil)
    query = User.eligible_parents(self).order(:upline)
    query = query.with_ancestor(user.id) if user && !user.role?(:admin)
    query
  end

  def eligible_parent?(parent_id, user = nil)
    eligible_parents(user).where(id: parent_id).exists?
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

  # KPI METHODS
  def weekly_growth
    User.with_ancestor(id).within_date_range(Time.now - 6.days, Time.now).count
  end

  def accepted_latest_terms?
    # TODO: cache current application agreement version
    # so we don't have to make a request
    return true if role?(:admin)
    current_version = ApplicationAgreement.current.try(:version)
    current_version.nil? || current_version == tos
  end

  def group?(group_id)
    user_user_groups.exists?(group_id.to_s)
  end

  def highest_rank
    @highest_rank ||= begin
      result = UserUserGroup.highest_ranks(id).entries.first
      result && result.attributes['highest_rank']
    end
  end

  def needs_rank_up?
    return false unless highest_rank
    organic_rank.nil? || organic_rank < highest_rank ||
      lifetime_rank.nil? || lifetime_rank < highest_rank
  end

  def rank_up!
    self.organic_rank = highest_rank
    self.lifetime_rank = highest_rank
    self.save!
  end

  def smarteru
    @smarteru ||= SmarteruClient.new(self)
  end

  def partner?
    product_receipts
      .joins(:product)
      .where(products: { slug: 'partner' }).count > 0
  end

  def mark_notifications_as_read=(*)
    self.notifications_read_at = Time.zone.now.to_s(:db)
  end

  def latest_unread_notification
    items = NotificationRelease.sorted
    if partner?
      items = items.for_partners
    else
      items = items.for_advocates
    end
    if notifications_read_at
      items = items
        .where('notification_releases.created_at > ?', notifications_read_at)
    end
    items.joins(:notification).includes(:notification).first.try(:notification)
  end

  def team_lead_count(lead_scope = Lead.submitted)
    lead_scope.joins(:user).merge(User.all_team(id)).count
  end

  private

  def set_url_slug
    self.url_slug = "#{first_name}-#{last_name}-#{SecureRandom.random_number(1000)}"
  end

  def hydrate_upline # rubocop:disable Metrics/AbcSize
    return if upline && !upline.empty?
    self.upline = sponsor ? sponsor.upline + [ id ] : [ id ]
    User.where(id: id).update_all(upline: upline)
  end

  class << self
    def update_organic_ranks
      joins_sql = needs_organic_rank_up.to_sql
      sql = "
        update users u
        set organic_rank = r.highest_rank
        from (#{joins_sql}) r
        where r.id = u.id;"
      connection.execute(sql)
    end

    def update_lifetime_ranks
      needs_lifetime_rank_up.update_all('lifetime_rank = organic_rank')
    end

    def rank_up
      update_organic_ranks
      update_lifetime_ranks
    end

    UPDATE_PARENT_SQL = \
      'upline = ARRAY[%s] || upline[%s:array_length(upline,1)]'
    def move_user(user, parent) # rubocop:disable Metrics/AbcSize
      if user.id == parent.id
        fail ArgumentError, 'A user cannot be their own parent'
      end
      if parent.ancestor?(user.id)
        fail ArgumentError, 'A parent cannot be moved to a child'
      end

      sql = format(UPDATE_PARENT_SQL, parent.upline.join(','), user.level)
      where('upline && ARRAY[?]', user.id).update_all(sql)
      user.update!(moved: true)
      user.upline = parent.upline + [ user.id ]
    end
  end
end
