class SmarteruClient
  attr_reader :user, :client

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
    @account ||= client.users.get(employee_id)
  end

  def account?
    !account.nil?
  end

  def create_account(opts = {})
    opts.reverse_merge!(
      email:        user.email,
      employee_i_d: normalized_employee_id,
      given_name:   user.first_name,
      surname:      user.last_name,
      password:     SecureRandom.urlsafe_base64(8),
      group:        group)

    response = client.users.create(opts)
    update_employee_id(response.result[:employee_id])
  end

  def signin
    response = client.users.signin(employee_id)
    response.result[:redirect_path]
  end

  def enroll(product)
    client.users.enroll(
      employee_id,
      group,
      product.smarteru_module_id)
  end

  def learner_report
    @learner_report ||= client.users.learner_report(employee_id, group)
  end

  def normalize_employee_id!
    return unless employee_id || employee_id == normalized_employee_id
    response = client.users.update(user.email, normalized_employee_id)
    update_employee_id(response.result[:employee_id])
  end

  def enrollment(product)
    enrollments = learner_report.select do |entry|
      entry[:course_name] == product.name
    end
    enrollments.sort_by do |e|
      e[:completed_date] ? 0 : (e[:started_date] ? 1 : 2)
    end.first
  end

  def enrolled?(product)
    !enrollment(product).nil?
  end

  private

  def env
    ENV['SMARTERU_ENV'] || Rails.env
  end

  def normalized_employee_id
    "#{env}.powur.com:#{user.id}"
  end

  def update_employee_id(value)
    user.update_column(:smarteru_employee_id, value)
  end
end
