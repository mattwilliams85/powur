require 'valid_email'

class Lead < ActiveRecord::Base
  include NameEmailSearch
  include Phone

  belongs_to :user
  belongs_to :product
  belongs_to :customer
  has_many :lead_updates

  enum data_status: [
    :incomplete, :ready_to_submit,
    :ineligible_location, :submitted ]
  enum sales_status: [
    :in_progress, :proposal, :closed_won, :contract, :installed,
    :duplicate, :ineligible, :closed_lost]
  enum invite_status: [
    :not_sent, :sent, :initiated, :accepted ]

  add_search :user, [ :user ]

  scope :not_submitted, -> { where('submitted_at IS NULL') }
  scope :submitted_status, -> (status) { send(status) }
  scope :data_status, lambda { |status|
    where('data_status = ?', Lead.data_statuses[status])
  }
  scope :sales_status, lambda { |status|
    where('sales_status = ?', Lead.sales_statuses[status])
  }
  USER_COUNT_SQL = 'user_id, COUNT(leads.id) lead_count'
  scope :user_count, -> { select(USER_COUNT_SQL).group(:user_id) }
  scope :team_leads, lambda { |user_id:, query: Lead.unscoped|
    query.joins(:user).merge(User.all_team(user_id))
  }
  scope :team_count, lambda { |user_id:, query: Lead.unscoped|
    query.joins(:user).merge(User.all_team(user_id)).count
  }
  scope :pay_period, ->(field, pp_id) { pay_period_query(field, pp_id) }
  scope :from_date, ->(field, from) { where("#{field} >= ?", from) }
  scope :to_date, ->(field, to) { where("#{field} < ?", to) }
  scope :timespan, lambda { |field:, pay_period_id: nil, from: nil, to: nil|
    query = where("#{field} IS NOT NULL")
    query = query.pay_period(field, pay_period_id) if pay_period_id
    query = query.from_date(field, from) if from
    query = query.to_date(field, to) if to
    query
  }
  KEY_DATES = [
    :submitted, :contracted, :converted,
    :closed_won, :installed, :created ]
  KEY_DATES.each do |key_date|
    scope key_date, lambda { |pay_period_id: nil, from: nil, to: nil|
      timespan(field:         "#{key_date}_at",
               pay_period_id: pay_period_id,
               from:          from,
               to:            to)
    }
  end

  before_validation do
    self.code ||= self.class.generate_code
  end

  class << self
    def generate_code(size = 3)
      code = SecureRandom.hex(size).upcase
      find_by(code: code) ? generate_code(size) : code
    end
  end

  validates_presence_of :product_id, :user_id
  validates_presence_of :first_name, :last_name,
                        :email, :phone, :address, :city, :state, :zip,
                        allow_nil: true
  validates_length_of :first_name, maximum: 40
  validates_length_of :last_name, maximum: 40
  validates :email, presence:   true,
                    email:      true, if: :email_present?
  def email_present?
    email?
  end

  validates_with ::Phone::Validator, fields: [:phone],
                                     if:     'phone.present?',
                                     on:     :create


  before_create :validate_data_status
  before_update :validate_data_status
  before_destroy { |record| !record.submitted? }

  def submit!
    fail 'Lead is not ready for submission' unless ready_to_submit?

    Rails.logger.info("Submitting lead to SC: #{id}")

    ENV['SIMULATE_LEAD_SUBMIT'] ? simulate_submit : submit_to_provider
  end

  def validate_data_status
    self.data_status = calculate_data_status
  end

  def last_update
    @last_update ||= lead_updates.order(updated_at: :desc, id: :desc).first
  end

  def last_update_has_key_changes?
    return false if converted_at? && contracted_at?
    (!converted_at? && last_update.converted) ||
      (!contracted_at? && last_update.contract)
  end

  def update_received
    update_last_update_attributes
  end

  def can_email?
    email && submitted_at?
  end

  def email_customer
    PromoterMailer.new_quote(self).deliver_later if can_email?
  end

  def full_name
    "#{first_name} #{last_name}"
  end

  def lead_stage
    Lead.sales_statuses[sales_status]
  end

  def converted_count_at_time
    @converted_count_at_time ||= begin
      Lead.converted(to: converted_at).where(user_id: user_id).count + 1
    end
  end

  def status_count_at_time(status, product_id = nil)
    @status_totals ||= {}
    key = product_id ? "status#{product_id}" : status
    @status_totals[key] ||= query_status_count(status, product_id)
  end

  def status_date(status)
    send("#{status}_at")
  end

  def lead_action?
    !lead_action.nil?
  end

  def action_copy
    lead_action && lead_action.action_copy
  end

  def completion_chance
    lead_action && lead_action.completion_chance
  end

  def action_badge
    lead_action? && !contract? && !installed?
  end

  def send_sms_invite
    return if phone.nil? || !valid_phone?(phone)

    opts = Rails.configuration.action_mailer.default_url_options
    # TODO: this will change when the new public page is ready
    join_url = URI.join("#{opts[:protocol]}://#{opts[:host]}",
                        'next/join/solar/',
                        code).to_s

    message = I18n.t('sms.solar_invite', name: user.full_name, url: join_url)

    twilio_client = TwilioClient.new
    twilio_client.send_message(
      to:   phone,
      from: twilio_client.numbers_for_personal_sms.sample,
      body: message)
  end

  def mandrill
    return nil unless mandrill_id
    @mandrill ||= MandrillMonitor.new(self)
  end

  def distinct_update_dates(date)
    lead_updates.select(date).distinct(date)
      .map { |lu| lu.send(date) }.compact
  end

  private

  def query_status_count(status, product_id = nil)
    at = status_date(status)
    return 0 unless at

    opts = { to: at }
    if product_id
      opts[:from] = user.purchased_at(product_id)
      return 0 if opts[:from].nil? || opts[:from] >= at
    end

    Lead.send(status, opts).where(user_id: user_id).count + 1
  end

  def submitted(provider_uid, at)
    update_columns(provider_uid: provider_uid,
                   submitted_at: at,
                   data_status:  Lead.data_statuses[:submitted])
  end

  class SolarCityApiError < StandardError; end

  def submit_to_provider
    form = SolarCityForm.new(self)
    form.post
    if form.error? && !form.dupe?
      fail(form.error.is_a?(Exception) ? form.error : "Lead post error?: #{form.error.inspect}")
    end

    if form.dupe?
      Rails.logger.error(
        'Lead#submit_to_provider duplicate error. ' \
        "Request: #{form.post_body} " \
        "Response: #{form.parsed_response}")
    end

    submitted(form.provider_uid, DateTime.parse(form.response.headers[:date]))
  rescue RestClient::RequestFailed => e
    raise SolarCityApiError.new, "Request failed to solar city: #{e.message}"
  rescue => e
    params = {
      response: form.response.inspect,
      error:    form.error.inspect }
    Airbrake.notify(e, parameters: params)
    raise e
  end

  def simulate_submit
    submitted("simulated:#{SecureRandom.hex(2)}", DateTime.current)
  end

  def complete?
    %w(first_name last_name email phone address city state zip).all? do |f|
      !attributes[f].nil?
    end
  end

  def calculate_data_status
    return :submitted if submitted_at?
    return :incomplete unless complete?
    return :ineligible_location unless Lead.eligible_zip?(zip)
    :ready_to_submit
  end

  def update_last_update_attributes
    return if last_update.nil?
    self.converted_at = last_update.converted
    self.closed_won_at ||= last_update.updated_at if last_update.closed_won?
    self.contracted_at ||= last_update.contract
    self.installed_at ||= last_update.installation
    self.sales_status = last_update.sales_status
    save!
  end

  def pre_submission_action
    LeadAction.where(data_status: Lead.data_statuses[data_status]).first
  end

  def sales_action
    LeadAction.where(sales_status: Lead.sales_statuses[sales_status]).first
  end

  def post_submission_action
    return nil if last_update.nil?
    stage = last_update.opportunity_stage.presence
    status = last_update.lead_status.presence
    return nil unless stage || status
    if stage
      LeadAction.where(opportunity_stage: stage).first
    else
      LeadAction.where(lead_status: status).first
    end
  end

  def lead_action
    @lead_action ||= begin
      if submitted?
        contract? || installed? ? sales_action : post_submission_action
      else
        pre_submission_action
      end
    end
  end

  class ZipApiError < StandardError; end

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

    def pay_period_query(field, pp_id)
      query =
        if pp_id =~ /W/
          year, week = pp_id.split('W')
          where("date_part('week', #{field}) = ?", week)
        else
          year, month = pp_id.split('-')
          where("date_part('month', #{field}) = ?", month)
        end
      query.where("date_part('year', #{field}) = ?", year)
    end

    def valid_zip?(zip)
      !!(/^\d{5}(-\d{4})?$/ =~ zip)
    end

    def eligible_zip?(zip)
      zip = zip.to_s[0, 5]
      path = "solarbid/api/warehouses/zip/#{zip}"
      url = URI.join('http://api.solarcity.com', path).to_s

      response = RestClient::Request.execute(method: :get, url: url, timeout: 3)
      MultiJson.load(response)['IsInTerritory']
    rescue SocketError, RestClient::RequestFailed
      url = URI.join('http://www.solarcity.com/api/zipcode/', zip).to_s
      begin
        response = RestClient::Request.execute(
          method:  :get,
          url:     url,
          timeout: 3)
        response == 'yes'
      rescue SocketError, RestClient::RequestFailed
        raise ZipApiError.new, 'Failure connecting to zip api'
      end
    end
  end
end
