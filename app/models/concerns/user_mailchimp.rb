module UserMailchimp
  extend ActiveSupport::Concern

  MAILCHIMP_LISTS = {
    all_users: 'c96e3429d7'
  }

  MAILCHIMP_INTERESTS = {
    advocates: 'd206678e9a',
    partners:  '7a346cbe4c'
  }

  # MAILCHIMP_GROUPINGS = {
  #   powur_path: 6265
  # }

  def mailchimp_enabled?
    !ENV['MAILCHIMP_API_KEY'].blank?
  end

  def mailchimp_client
    @mailchimp_client ||= Gibbon::Request.new(api_key: ENV['MAILCHIMP_API_KEY'])
  end

  def mailchimp_group_name
    partner? ? ['Partner'] : ['Advocate']
  end

  def mailchimp_merge_fields
    { FNAME: first_name,
      LNAME: last_name }
  end

  def mailchimp_subscribe
    return unless mailchimp_enabled?

    response = mailchimp_client
      .lists(MAILCHIMP_LISTS[:all_users])
      .members.create(
        body: {
          email_address: email,
          interests:     {
            MAILCHIMP_INTERESTS[:partners]  => partner?,
            MAILCHIMP_INTERESTS[:advocates] => !partner? },
          status:        'subscribed',
          merge_fields:  mailchimp_merge_fields })
    update_attribute(:mailchimp_id, response['id'])
    response
  end

  def mailchimp_update_subscription
    return unless mailchimp_enabled?

    mailchimp_client
      .lists(MAILCHIMP_LISTS[:all_users])
      .members(mailchimp_id)
      .update(
        body: {
          interests:    {
            MAILCHIMP_INTERESTS[:partners]  => partner?,
            MAILCHIMP_INTERESTS[:advocates] => !partner? },
          merge_fields: mailchimp_merge_fields
        })
  end

  def mailchimp_unsubscribe
    return unless mailchimp_enabled?

    mailchimp_client
      .lists(MAILCHIMP_LISTS[:all_users])
      .members(mailchimp_id)
      .update(body: { status: 'unsubscribed' })
  end
end
