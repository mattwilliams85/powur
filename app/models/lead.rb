class Lead < ActiveRecord::Base
  belongs_to :user
  belongs_to :product
  belongs_to :customer
  has_many :lead_updates

  enum data_status: [
    :incomplete, :ready_to_submit,
    :ineligible_location, :submitted ]
  enum sales_status: [
    :in_progress, :proposal, :contract, :installed,
    :duplicate, :ineligible, :closed_lost ]

  add_search :user, :customer, [ :user, :customer ]

  scope :not_submitted, -> { where('submitted_at IS NULL') }
  scope :submitted_status, -> (status) { send(status) }
  scope :data_status, -> (status) { send(status) }
  scope :sales_status, -> (status) { send(status) }
  scope :proposals, -> { where('converted_at IS NOT NULL') }
  scope :contracts, -> { where('contract_at IS NOT NULL') }
  scope :rooftops, -> { where('install_at IS NOT NULL') }
  scope :user_count, lambda {
    Lead
      .submitted
      .select('user_id, count(id) lead_count')
      .group(:user_id)
  }

  validates_presence_of :product_id, :customer_id, :user_id

  before_create :validate_data_status
  before_update :validate_data_status

  def submit!
    fail 'Lead is not ready for submission' unless ready_to_submit?

    ENV['SIMULATE_LEAD_SUBMIT'] ? simulate_submit : submit_to_provider
  end

  def validate_data_status
    self.data_status = calculate_data_status
  end

  def last_update
    @last_update ||= lead_updates.order(updated_at: :desc, id: :desc).first
  end

  def update_received
    self.converted_at = last_update.converted
    self.contract_at = last_update.contract
    self.install_at = last_update.installation
    self.sales_status = last_update.sales_status
    save!
  end

  def can_email?
    customer.email && submitted_at?
  end

  def email_customer
    PromoterMailer.new_quote(self).deliver_later if can_email?
  end

  private

  def submitted(provider_uid, at)
    update_columns(provider_uid: provider_uid,
                   submitted_at: at,
                   data_status:  Lead.data_statuses[:submitted])
  end

  def submit_to_provider
    form = SolarCityForm.new(self)
    form.post
    fail(form.error) if form.error? && !form.dupe?
    
    submitted(form.provider_uid, DateTime.parse(form.response.headers[:date]))
  end

  def simulate_submit
    submitted("simulated:#{SecureRandom.hex(2)}", DateTime.current)
  end

  def valid_zip?
    return false unless customer.zip?
    path = "solarbid/api/warehouses/zip/#{customer.zip[0, 5]}"
    url = URI.join('http://api.solarcity.com', path).to_s

    response = RestClient::Request.execute(method: :get, url: url, timeout: 3)
    MultiJson.load(response)['IsInTerritory']
  end

  def calculate_data_status
    return :submitted if submitted_at?
    return :incomplete unless customer.complete?
    return :ineligible_location unless valid_zip?
    :ready_to_submit
  end

  class << self
    def find_for_downline(id, parent_id)
      Lead.where(id: id)
        .joins(:user).merge(User.where('? = ANY (upline)', parent_id)).first
    end

    def id_prefix
      sub = ENV['DATA_API_ENV'] || Rails.env
      "#{sub}.powur.com"
    end

    def id_to_external(id)
      "#{id_prefix}:#{id}"
    end

    def find_by_external_id(external_id)
      prefix, lead_id = external_id.split(':')
      return nil unless prefix == id_prefix
      Lead.find(lead_id.to_i)
    end
  end
end
