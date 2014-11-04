class User < ActiveRecord::Base
  include UserSecurity
  include UserInvites
  include NameEmailSearch
  include UserScopes

  validates :email, email: true, presence: true
  validates_presence_of :encrypted_password, on: :create
  validates_presence_of :first_name, :last_name
  validates_presence_of :url_slug, :reset_token, allow_nil: true
  store_accessor :contact, :address, :city, :state, :zip, :phone
  store_accessor :utilities, :provider, :monthly_bill
  store_accessor :profile, :bio, :twitter_url, :linkedin_url, :facebook_url, :avatar, :avatar_file_name
  validates_presence_of :phone, :zip
  validates_presence_of :address, :city, :state, allow_nil: true

  has_many :quotes
  has_many :customers, through: :quotes
  has_many :orders
  has_many :order_totals
  has_many :rank_achievements
  has_many :bonus_payments
  has_many :overrides, class_name: 'UserOverride'
  has_many :user_activities

  attr_accessor :remove_avatar
  attr_accessor :avatar_content_type, :avatar_file_name

  has_attached_file :avatar,
                    path:            '/avatars/:id/:basename_:style.:extension',
                    url:             ':s3_domain_url',
                    default_url:     '/assets/default_avatars/avatar_defaults-04.jpg',
                    storage:         :s3,
                    s3_credentials:  { bucket: ENV['AWS_BUCKET'],
                                       access_key_id: ENV['AWS_ACCESS_KEY_ID'],
                                       secret_access_key: ENV['AWS_SECRET_ACCESS_KEY'] },
                    styles:          {
                    thumb:   [ '100x100#', :jpg, quality: 70 ],
                    preview: [ '480x480#', :jpg, quality: 70 ],
                    large:   [ '600>',     :jpg, quality: 70 ],
                    retina:  [ '1200>',    :jpg, quality: 30 ] },
                    convert_options: {
                      thumb:   '-set colorspace sRGB -strip',
                      preview: '-set colorspace sRGB -strip',
                      large:   '-set colorspace sRGB -strip',
                      retina:  '-set colorspace sRGB -strip -sharpen 0x0.5' }

  # Validate content type
  validates_attachment_content_type :avatar, content_type: /\Aimage/
  # Validate filename
  validates_attachment_file_name :avatar, matches: [/png\Z/, /jpe?g\Z/, /gif\Z/]
  # Explicitly do not validate
  do_not_validate_attachment_file_type :avatar

  #before_save :delete_avatar, if: -> { remove_avatar == '1' && !avatar_updated_at_changed? }

  after_create :set_upline

  attr_accessor :child_order_totals, :pay_period_rank

  before_validation do
    self.lifetime_rank ||= Rank.find_or_create_by_id(1).id
    self.organic_rank ||= 1
  end

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
    User.with_downline_counts.with_parent(self.id)
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

  def image_url(image_size = 'thumb')
    full_file_name = avatar_file_name
    split_name = full_file_name.split('.')
    filename = split_name[0]
    extension = split_name[1]
    #url = https://s3.amazonaws.com/sunstand-dev/avatars/:user_id/name_<size>
    base_avatar_url = 'https://s3.amazonaws.com/sunstand-dev/avatars/'
    return_url = base_avatar_url + self.id.to_s + '/' + filename + '_' + image_size + '.' + extension
    return return_url
  end

  private

  def set_upline
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

  def delete_avatar
    self.avatar = nil
  end
end
