class User < ActiveRecord::Base
  include UserSecurity
  include UserInvites
  include NameEmailSearch
  include UserScopes
  include PaperclipScopes
  include Phone
  include UserMailchimp
  include UserEwallet

  has_many :leads
  has_many :customers
  has_many :bonus_payments
  has_many :overrides, class_name: 'UserOverride'
  has_many :user_activities
  has_many :product_receipts
  has_many :product_enrollments, dependent: :destroy
  has_many :lead_totals, class_name: 'LeadTotals', dependent: :destroy
  has_many :user_ranks, dependent: :destroy
  has_many :ranks, through: :user_ranks
  has_many :sent_invites, class_name:  'Invite',
                          foreign_key: :sponsor_id,
                          dependent:   :destroy
  has_one :accepted_invite, class_name:  'Invite',
                            foreign_key: :user_id,
                            dependent:   :destroy

  store_accessor :contact,
                 :address, :city, :state, :country, :zip, :phone, :valid_phone
  store_accessor :profile,
                 :bio, :twitter_url, :linkedin_url, :facebook_url,
                 :communications, :watched_intro, :tos_version,
                 :allow_sms, :allow_system_emails, :allow_corp_emails,
                 :notifications_read_at,
                 :ewallet_username, :mailchimp_id

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

  def parent
    @parent ||= parent_id && User.find(parent_id)
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

  def make_customer!
    Customer.create!(first_name: first_name, last_name: last_name, email: email)
  end

  def pay_as_rank(pay_period_id = nil)
    pay_period_id ||= MonthlyPayPeriod.current_id
    return organic_rank || 0 if pay_period_id =~ /W/

    highest_rank =
      if user_ranks.loaded?
        user_ranks.entries.select do |user_rank|
          user_rank.pay_period_id == pay_period_id
        end.map(&:rank_id).max
      else
        query_highest_rank(pay_period_id)
      end
    highest_rank || 0
  end

  def override_rank(pay_period_id)
    override = overrides.entries.detect do |o|
      o.pay_as_rank? && o.pay_period?(pay_period_id)
    end
    override && override.rank.to_i
  end

  def pay_period_rank(pp_id)
    @pay_period_ranks ||= {}
    @pay_period_ranks[pp_id] ||= override_rank(pp_id) || pay_as_rank(pp_id)
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

  def smarteru
    @smarteru ||= SmarteruClient.new(self)
  end

  def partner?
    !lifetime_rank.nil? && lifetime_rank >= 1
  end

  def purchased_at(product_id)
    purchase = product_receipts.entries.detect do |pr|
      pr.product_id == product_id
    end
    purchase && purchase.purchased_at
  end

  def mark_notifications_as_read=(*)
    self.notifications_read_at = Time.zone.now.to_s(:db)
  end

  def latest_unread_notification
    items = NotificationRelease.sorted
    items = partner? ? items.for_partners : items.for_advocates
    if notifications_read_at
      items = items
        .where('notification_releases.created_at > ?', notifications_read_at)
    end
    items.joins(:notification).includes(:notification).first.try(:notification)
  end

  def team_lead_count(lead_scope = Lead.submitted)
    lead_scope.joins(:user).merge(User.all_team(id)).count
  end

  def validate_phone_number!
    update_attribute(:valid_phone, twilio_valid_phone(phone))
  end

  def breakage_account?
    role?(:breakage_account)
  end

  def reconcile_invites
    update_column(:available_invites, 0) if available_invites < 0
    return if available_invites > 0
    available = case invites.redeemed.count
                when (0...9) then 5
                when (10..19) then 10
                else 20
                end
    pending = invites.pending.count
    amount_to_add = available - pending
    return if amount_to_add < 1
    update_column(:available_invites, amount_to_add)
  end

  def metrics
    @metrics ||= Metrics.new(self)
  end

  class Metrics
    attr_reader :user

    def initialize(user)
      @user = user
    end

    def team_count
      @team_count ||= User.with_ancestor(user.id).count
    end

    def earnings
      @earnings ||= user.bonus_payments.where(status: [ 2, 4 ]).sum(:amount)
    end

    def co2_saved
      @co2_saved ||= begin
        lb = 0
        homes = User.installations(user.id).pluck(:installed_at)
        homes.each do |home|
          lb += (Time.now - home) / 1.days * 0.133
        end
        lb * 1000
      end
    end

    def team_leads
      @team_leads ||= Lead.team_count(user_id: user.id, query: Lead.submitted)
    end

    def login_streak
      user.login_streak
    end
  end

  private

  def set_url_slug
    self.url_slug = \
      "#{first_name}-#{last_name}-#{SecureRandom.random_number(1000)}"
  end

  def hydrate_upline # rubocop:disable Metrics/AbcSize
    return if upline && !upline.empty?
    self.upline = sponsor ? sponsor.upline + [ id ] : [ id ]
    User.where(id: id).update_all(upline: upline)
  end

  def query_highest_rank(pay_period_id)
    result = user_ranks.highest_ranks
      .where(pay_period_id: pay_period_id).entries.first
    result && result.attributes['rank_id']
  end

  class << self
    def update_organic_ranks
      join = UserRank.highest_lifetime_ranks.to_sql
      sql = "
        UPDATE users u
        SET organic_rank = hr.rank_id
        FROM (#{join}) hr
        WHERE hr.user_id = u.id
          AND (u.organic_rank IS NULL OR u.organic_rank < hr.rank_id);"
      connection.execute(sql).cmdtuples
    end

    def update_lifetime_ranks
      join = UserRank.highest_ranks
      sql = "
        UPDATE users u
        SET lifetime_rank = hr.rank_id
        FROM (#{join.to_sql}) hr
        WHERE hr.user_id = u.id
          AND (u.lifetime_rank IS NULL OR u.lifetime_rank < hr.rank_id);"
      connection.execute(sql).cmdtuples
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
      user.upline = parent.upline + [ user.id ]
    end

    def validate_phone_number!(id)
      find(id).validate_phone_number!
    end

    def nullify_phone_number!(number)
      users = where([
        "contact->'phone' = ? OR contact->'valid_phone' = ?",
        number, number ])
      users.each do |user|
        user.update_attributes(phone: nil, valid_phone: nil)
      end
    end
  end
end
