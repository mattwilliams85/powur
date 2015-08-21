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
    @mailchimp_client ||= Gibbon::Request.new(api_key: ENV['MAILCHIMP_API_KEY'])
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
    mailchimp_client.lists(MAILCHIMP_LISTS[:all_users]).members.create(
      body: {
        email_address: email,
        merge_vars:    mailchimp_merge_vars })
  end

  def mailchimp_update_subscription(old_email = nil)
    return unless mailchimp_enabled?

    mailchimp_client.lists(MAILCHIMP_LISTS[:all_users]).members.update(
      body: {
        email_address: old_email || email,
        merge_vars:    mailchimp_merge_vars })
  end

  def mailchimp_unsubscribe(list_name)
    return unless mailchimp_enabled?

    mailchimp_client.lists(MAILCHIMP_LISTS[list_name.to_sym]).members.delete(
      body: {
        email_address: email,
        delete_member: true,
        send_notify:   false })
  end
end
