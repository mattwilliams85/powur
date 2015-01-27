module UserSmarteru
  extend ActiveSupport::Concern

  def smarteru_client
    @smarteru_client ||= Smarteru::Client.new(
      account_api_key: Rails.application.secrets.smarteru_account_api_key,
      user_api_key: Rails.application.secrets.smarteru_user_api_key
    )
  end

  def has_smarteru_account?
    !!smarteru_employee_id
  end

  def create_smarteru_account(opts={})
    return true if has_smarteru_account?

    password = opts.delete(:password) || SecureRandom.urlsafe_base64(8)
    payload = {
      user: {
        info: {
          email: email,
          employee_i_d: id,
          given_name: first_name,
          surname: last_name,
          password: password,
          learner_notifications: 1,
          supervisor_notifications: 0,
          send_email_to: 'Self',
        },
        profile: {
          home_group: Rails.application.secrets.smarteru_group_name
        },
        groups: {
          group: {
            group_name: Rails.application.secrets.smarteru_group_name,
            group_permissions: ''
          }
        }
      }
    }

    response = smarteru_client.request('createUser', payload)

    if response.success?
      self.update_column(:smarteru_employee_id, id)
      return true
    else
      return false
    end
  end

  def smarteru_enroll product
    payload = {
      learning_module_enrollment: {
        enrollment: {
          user: {
            employee_i_d: smarteru_employee_id,
          },
          group_name: Rails.application.secrets.smarteru_group_name,
          learning_module_i_d: '5248' # product.smarteru_module_id
        }
      }
    }
    response = smarteru_client.request('enrollLearningModules', payload)
    return response.success?
  end
end
