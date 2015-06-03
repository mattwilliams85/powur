class User < ActiveRecord::Base
  include UserSecurity
  include UserInvites
  include NameEmailSearch
  include UserScopes
  include PaperclipScopes
  include UserSmarteru

  belongs_to :rank_path

  has_many :quotes
  has_many :customers, through: :quotes
  has_many :orders
  has_many :order_totals
  has_many :rank_achievements
  has_many :bonus_payments
  has_many :overrides, class_name: 'UserOverride'
  has_many :user_activities
  has_many :product_enrollments, dependent: :destroy
  has_many :user_user_groups, dependent: :destroy
  has_many :user_groups, through: :user_user_groups

  store_accessor :contact,
                 :address, :city, :state, :country, :zip, :phone
  store_accessor :profile,
                 :bio, :twitter_url, :linkedin_url, :facebook_url,
                 :communications

  # No extra email validation needed,
  # email validation and confirmation happens with Invite
  validates :email,
    uniqueness: { message: 'This email is taken', case_sensitive: false },
    presence: true
  validates :encrypted_password, presence: true, on: :create
  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :password,
    presence: true,
    length: { minimum: 8, maximum: 40, message: 'Password not less than 8 symbols' },
    confirmation: true,
    on: :create
  validates :password_confirmation, presence: true, on: :create
  validates_presence_of :url_slug, :reset_token, allow_nil: true
  # validates_presence_of :address, :city, :state, allow_nil: true
  validates :tos,
            presence: { message: 'Please read and agree to the terms and conditions in the Application and Agreement' }
  validate :latest_agreement_version, on: :create
  def latest_agreement_version
    latest_agreement = ApplicationAgreement.current
    if latest_agreement && latest_agreement.version != tos
      errors.add(:tos, 'Outdated terms and conditions')
    end
  end

  before_create :set_url_slug
  before_create :destroy_used_invite
  after_create :hydrate_upline

  attr_reader :password
  attr_accessor :child_order_totals, :pay_period_rank, :pay_period_quote_count,
                :password_confirmation

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
    User.with_parent(self.id)
  end

  def downline_users_count(id)
    User.with_parent(id).count
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

  def placeable?(current_user)
    ((Time.now - created_at) / 86400) <= 60 && sponsor_id == current_user.id
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
  def proposal_count
    quotes.submitted.count
  end

  def fetch_proposal_metrics(start_date, end_date)
    {
      data0: orders.within_date_range(start_date, end_date),
      data1: complete_quotes.within_date_range(start_date, end_date).status(:submitted)
    }
  end

  def complete_quotes
    quotes.where.not(id: self.orders.select('quote_id').map {|i| i})
  end

  def full_downline_count
    @count = 0
    count_children(self.id)
  end

  def count_children(parent_id)
    downline = User.with_parent(parent_id).pluck(:id)
    return if !downline.length
    @count += downline.length
    downline.each do |user_id|
      count_children(user_id)
    end
    @count
  end
  ##

  def assign_parent(parent, params)
    self.class.move_user(self, parent)
    if params != 'admin'
      self.update(moved: true)
    end
  end

  def group?(group_id)
    user_user_groups.exists?(group_id.to_s)
  end

  def accepted_latest_terms?
    # TODO: cache current application agreement version
    # so we don't have to make a request
    return true if role?(:admin)
    current_version = ApplicationAgreement.current.try(:version)
    current_version.nil? || current_version == tos
  end

  private

  def destroy_used_invite
    Invite.find_by(email: '#{email}').destroy! if Invite.find_by(email: '#{email}')
  end

  def set_url_slug
    self.url_slug = "#{first_name}-#{last_name}-#{SecureRandom.random_number(1000)}"
  end

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

    UPDATE_PARENT = "upline = ARRAY[%s] || upline[%s:array_length(upline,1)]"

    def move_user(user, parent)
      if user.id == parent.id
        fail ArgumentError, 'A user cannot be their own parent'
      end
      if parent.ancestor?(user.id)
        fail ArgumentError, 'A parent cannot be moved to a child'
      end
      sql = UPDATE_PARENT % [ parent.upline.join(','), user.level ]
      where("upline && ARRAY[?]", user.id).update_all(sql)
      user.upline = parent.upline + [ user.id ]
    end
  end
end
