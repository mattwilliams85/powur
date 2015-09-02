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
  KEY_DATES = [ :submitted, :contracted, :converted, :installed, :created ]
  KEY_DATES.each do |key_date|
    scope key_date, lambda { |pay_period_id: nil, from: nil, to: nil|
      timespan(field:         "#{key_date}_at",
               pay_period_id: pay_period_id,
               from:          from,
               to:            to)
    }
  end

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

  def last_update_has_key_changes?
    return false if converted_at? && contracted_at?
    (!converted_at? && last_update.converted) ||
      (!contracted_at? && last_update.contract)
  end

  def update_received
    update_last_update_attributes
  end

  def can_email?
    customer.email && submitted_at?
  end

  def email_customer
    PromoterMailer.new_quote(self).deliver_later if can_email?
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

  def update_last_update_attributes
    self.converted_at = last_update.converted
    self.contracted_at = last_update.contract
    self.installed_at = last_update.installation
    self.sales_status = last_update.sales_status
    save!
  end

  def lead_action
    return nil if submitted? && last_update.nil?
    @lead_action ||= begin
      stage = last_update.opportunity_stage.presence
      status = last_update.lead_status.presence
      if stage
        LeadAction.where(opportunity_stage: stage).first
      elsif status
        LeadAction.where(lead_status: status).first
      elsif !submitted?
        LeadAction
          .where(data_status: LeadAction.data_statuses[data_status]).first
      end
    end
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
  end
end
