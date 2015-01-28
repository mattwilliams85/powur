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

  # Create SmarterU account with user's data
  #
  # ==== Attributes
  # * +opts+ - options to overwrite payload for the SmarterU API request
  # ==== Example
  # user.create_smarteru_account(password: 'mypassword')
  # => true/false
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

    unless response.success?
      Airbrake.notify(response.error)
      return false
    end
    update_column(:smarteru_employee_id, id)
    return true
  end

  # Enroll user in a SmarterU class
  # Using user's employee_id and class's module_id
  #
  # ==== Attributes
  # * +product+ - Instance of a product that has smarteru module_id association
  # ==== Example
  # user.smarteru_enroll(product)
  # => true/false
  def smarteru_enroll(product)
    payload = {
      learning_module_enrollment: {
        enrollment: {
          user: {
            employee_i_d: smarteru_employee_id
          },
          group_name: Rails.application.secrets.smarteru_group_name,
          learning_module_i_d: product.smarteru_module_id
        }
      }
    }
    response = smarteru_client.request('enrollLearningModules', payload)
    # Success, either enroll or  already enrolled
    if response.result.present? || (response.error && response.error[:error][:error_id] == 'ELM:19')
      return self.product_enrollments.find_or_create_by(product_id: product.id)
    end
    Airbrake.notify(response.error)
    false
  end

  # Sign User In to the SmarterU web app
  # Provides a url that is valid for 60 seconds
  #
  #   user.smarteru_sign_in
  #   => 'http://urlwithkeys'
  def smarteru_sign_in
    payload = {
      security: {
        employee_i_d: smarteru_employee_id
      }
    }
    response = smarteru_client.request('requestExternalAuthorization', payload)
    unless response.success?
      Airbrake.notify(response.error)
      return false
    end
    response.result[:redirect_path]
  end
end
