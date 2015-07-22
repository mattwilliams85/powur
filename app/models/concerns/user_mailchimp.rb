module UserMailchimp
  extend ActiveSupport::Concern

  MAILCHIMP_LISTS = {
    all:      'c96e3429d7',
    partners: 'a5d562e9f8'
  }

  def mailchimp_enabled?
    !ENV['MAILCHIMP_API_KEY'].blank?
  end

  def mailchimp_client
    @mailchimp_client ||= Gibbon::API.new
  end

  def mailchimp_subscribe_to(list_name)
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
end
