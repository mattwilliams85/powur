module UserMailchimp
  extend ActiveSupport::Concern

  MAILCHIMP_LISTS = {
    all_users: 'c96e3429d7'
  }

  MAILCHIMP_GROUPINGS = {
    powur_path: 6265
  }

  def mailchimp_enabled?
    !ENV['MAILCHIMP_API_KEY'].blank?
  end

  def mailchimp_client
    @mailchimp_client ||= Gibbon::API.new
  end

  def mailchimp_group_name
    partner? ? ['Partner'] : ['Advocate']
  end

  def mailchimp_merge_vars
    { FNAME:     first_name,
      LNAME:     last_name,
      email:     email,
      groupings: [
        # subscribe to Advocate group by default
        { id: MAILCHIMP_GROUPINGS[:powur_path], groups: mailchimp_group_name }
      ]
    }
  end

  def mailchimp_subscribe
    return unless mailchimp_enabled?

    mailchimp_client.lists.subscribe(
      id:           MAILCHIMP_LISTS[:all_users],
      email:        { email: email },
      merge_vars:   mailchimp_merge_vars,
      double_optin: false)
  end

  def mailchimp_update_subscription(old_email = nil)
    return unless mailchimp_enabled?

    mailchimp_client.lists.update_member(
      id:         MAILCHIMP_LISTS[:all_users],
      email:      { email: old_email || email },
      merge_vars: mailchimp_merge_vars)
  end

  def mailchimp_unsubscribe(list_name)
    return unless mailchimp_enabled?

    mailchimp_client.lists.unsubscribe(
      id:            MAILCHIMP_LISTS[list_name.to_sym],
      email:         { email: email },
      delete_member: true,
      send_notify:   false)
  end
end
