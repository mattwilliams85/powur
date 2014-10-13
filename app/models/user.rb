class User < ActiveRecord::Base
  include UserSecurity
  include UserInvites
  include NameEmailSearch

  validates :email, email: true, presence: true
  validates_presence_of :encrypted_password, on: :create
  validates_presence_of :first_name, :last_name
  validates_presence_of :url_slug, :reset_token, allow_nil: true
  store_accessor :contact, :address, :city, :state, :zip, :phone
  store_accessor :utilities, :provider, :monthly_bill
  store_accessor :profile, :bio, :twitter_url, :linkedin_url, :facebook_url
  validates_presence_of :phone, :zip
  validates_presence_of :address, :city, :state, allow_nil: true

  has_many :quotes
  has_many :customers, through: :quotes
  has_many :orders
  has_many :order_totals
  has_many :rank_achievements
  has_many :bonus_payments
  has_many :overrides, class_name: 'UserOverride'

  attr_accessor :remove_avatar
  attr_accessor :avatar_content_type, :avatar_file_name

  has_attached_file :avatar,
    path:   ':rails_root/public/system/:class/:attachement/:id/:basename_:style.:extension',
    url:    '/system/:class/:attachement/:id/:basename_:style.:extension',
    styles: {
      thumb:   ['100x100#',  :jpg, :quality => 70],
      preview: ['480x480#',  :jpg, :quality => 70],
      large:   ['600>',      :jpg, :quality => 70],
      retina:  ['1200>',     :jpg, :quality => 30]
    },
    convert_options: {
      thumb:   '-set colorspace sRGB -strip',
      preview: '-set colorspace sRGB -strip',
      large:   '-set colorspace sRGB -strip',
      retina:  '-set colorspace sRGB -strip -sharpen 0x0.5' }

  # Validate content type
  validates_attachment_content_type :avatar, :content_type => /\Aimage/
  # Validate filename
  validates_attachment_file_name :avatar, :matches => [/png\Z/, /jpe?g\Z/, /gif\Z/]
  # Explicitly do not validate
  do_not_validate_attachment_file_type :avatar

  # validates_attachment :avatar,
  #   :presence => true,
  #   :size => { :in => 0..10.megabytes },
  #   :content_type => { :content_type => /^image\/(jpeg|png|gif|tiff)$/ }
  before_save :delete_avatar, if: ->{ remove_avatar == '1' && !avatar_updated_at_changed? }
   

  after_create :set_upline
  
  scope :with_upline_at, ->(id, level) {
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

  attr_accessor :child_order_totals, :pay_period_rank

  before_validation do
    self.lifetime_rank ||= Rank.find_or_create_by_id(1).id
    self.organic_rank ||= 1
  end

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
    upline.size
  end

  def downline_users
    User.child_count_list(self)
  end

  def has_role?(role)
    roles.include?(role.to_s)
  end

  def parent_id
    upline[-2]
  end

  def has_parent?
    !!parent_id
  end

  def parent_ids
    upline[0..-2]
  end

  def lifetime_achievements
    @lifetime_achievements ||= rank_achievements.
      where('pay_period_id is not null').order(rank_id: :desc, path: :asc).entries
  end

  def make_customer!
    Customer.create!(first_name: first_name, last_name: last_name, email: email)
  end

  def pay_as_rank
    pay_period_rank || organic_rank
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

  def delete_avatar
    self.avatar = nil
  end
end
