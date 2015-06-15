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
      employee_i_d: "#{env}.powur.com:#{user.id}",
      given_name:   user.first_name,
      surname:      user.last_name,
      password:     SecureRandom.urlsafe_base64(8),
      group:        group)

    response = client.users.create(opts)
    user.update_column(:smarteru_employee_id, response.result[:employee_id])
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
    client.users.learner_report(employee_id, group)
  end

  private

  def env
    ENV['SMARTERU_ENV'] || Rails.env
  end
end
