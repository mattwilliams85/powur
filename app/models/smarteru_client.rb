class SmarteruClient
  attr_reader :user, :client

  INACCESSABLE_ERROR = 'GU:04'

  def initialize(user)
    @user = user
    @client = Smarteru::Client.new
  end

  def employee_id
    user.smarteru_employee_id
  end

  def group
    ENV['SMARTERU_GROUP_NAME']
  end

  def account
    @account ||= begin
      response = client.users.get(employee_id || user.email)
      if response && response[:employee_id] != employee_id
        update_employee_id(response[:employee_id])
      end
      response
    end
  end

  def account?
    !account.nil?
  end

  def email_account?
    !client.users.get(user.email).nil?
  end

  def create_account(opts = {})
    opts = new_account_opts(opts)

    response = client.users.create(opts)
    update_employee_id(response.result[:employee_id])
  end

  def ensure_account
    create_account unless account?
  end

  def signin
    response = client.users.signin(employee_id)
    response.result[:redirect_path]
  end

  def enroll(product)
    existing_enrollment = enrollment(product)
    if existing_enrollment
      ensure_powur_enrollment(product)
      return existing_enrollment
    end

    begin
      client.users.enroll(
        employee_id,
        group,
        product.smarteru_module_id)
    rescue Smarteru::Error => e
      raise(e) unless e.code == 'ELM:19'
    end

    ensure_powur_enrollment(product)
  end

  def ensure_powur_enrollment(product)
    user.product_enrollments.find_or_create_by(product_id: product.id)
  end

  def learner_report
    @learner_report ||= client.users.learner_report(employee_id, group)
  end

  def normalize_employee_id!
    return if employee_id == normalized_employee_id || !email_account?

    response = client.users.update_employee_id(
      user.email,
      normalized_employee_id)
    update_employee_id(response.result[:employee_id])
  rescue Smarteru::Error => e
    raise(e) unless e.code == INACCESSABLE_ERROR
    @inaccessable_account = true
    update_employee_id(user.email)
  end

  def enrollment(product)
    enrollments = learner_report.select do |entry|
      entry[:course_name] == product.name
    end
    enrollments.sort_by do |e|
      if e[:completed_date]
        0
      elsif e[:started_date]
        1
      else
        2
      end
    end.first
  end

  def enrolled?(product)
    !enrollment(product).nil?
  end

  private

  def new_account_opts(opts = {})
    { email:        user.email,
      employee_i_d: normalized_employee_id,
      given_name:   user.first_name,
      surname:      user.last_name,
      password:     SecureRandom.urlsafe_base64(8),
      group:        group }.merge(opts)
  end

  def normalized_employee_id
    "powur:#{user.id}"
  end

  def update_employee_id(value)
    user.update_column(:smarteru_employee_id, value)
  end
end
