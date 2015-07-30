module UserMailchimp
  extend ActiveSupport::Concern

  MAILCHIMP_LISTS = {
    advocates: 'f52819c306',
    partners:  'a5d562e9f8'
  }

  def mailchimp_enabled?
    !ENV['MAILCHIMP_API_KEY'].blank?
  end

  def mailchimp_client
    @mailchimp_client ||= Gibbon::API.new
  end

  def mailchimp_subscribe(list_name)
    return unless mailchimp_enabled?

    mailchimp_client.lists.subscribe(
      id:           MAILCHIMP_LISTS[list_name.to_sym],
      email:        { email: email },
      merge_vars:   {
        FNAME: first_name,
        LNAME: last_name
      },
      double_optin: false)
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
