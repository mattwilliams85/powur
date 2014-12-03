class User < ActiveRecord::Base
  include UserSecurity
  include UserInvites
  include NameEmailSearch
  include UserScopes

  # validates :email, email: true, presence: true
  validates_presence_of :email
  validates_presence_of :encrypted_password, on: :create
  validates_presence_of :first_name, :last_name
  validates_presence_of :url_slug, :reset_token, allow_nil: true
  store_accessor :contact, :address, :city, :state, :zip, :phone
  store_accessor :utilities, :provider, :monthly_bill
  store_accessor :profile, :bio, :twitter_url, :linkedin_url, :facebook_url
  store_accessor :large_image_url, :medium_image_url, :thumb_image_url
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

  aws_bucket = Rails.application.secrets.aws_bucket
  aws_access_key_id = Rails.application.secrets.aws_access_key_id
  aws_secret_key = Rails.application.secrets.aws_secret_access_key
  has_attached_file :avatar,
                    path:            '/avatars/:id/:basename_:style.:extension',
                    url:             ':s3_domain_url',
                    default_url:     '/temp_dev_images/Tim.jpg',
                    storage:         :s3,
                    s3_credentials:  { bucket:            aws_bucket,
                                       access_key_id:     aws_access_key_id,
                                       secret_access_key: aws_secret_key },
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

  after_create :set_upline

  attr_accessor :child_order_totals, :pay_period_rank, :pay_period_quote_count

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

  def image_url(image_size = 'thumb')
    if !avatar_file_name.nil?
      full_file_name = avatar_file_name
      split_name = full_file_name.split('.')
      filename = split_name[0]
      extension = split_name[1]
      base_avatar_url = 'https://s3.amazonaws.com/' +
                        Rails.application.secrets.aws_bucket + '/avatars/'
      return_url = base_avatar_url + id.to_s + '/' + filename +
                   '_' + image_size + '.' + extension
    else
      return_url = nil
    end
  end

  def large_image_url
    image_url('large')
  end

  def medium_image_url
    image_url('medium')
  end

  def thumb_image_url
    image_url('thumb')
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
