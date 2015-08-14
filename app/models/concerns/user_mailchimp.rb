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

  def mailchimp_subscribe
    return unless mailchimp_enabled?

    mailchimp_client.lists.subscribe(
      id:           MAILCHIMP_LISTS[:all_users],
      email:        { email: email },
      merge_vars:   {
        FNAME: first_name,
        LNAME: last_name,
        groupings: [
          # subscribe to Advocate group by default
          { id: MAILCHIMP_GROUPINGS[:powur_path], groups: [ "Advocate" ] }
        ]
      },
      double_optin: false)
  end

  def mailchimp_move_to_group(group_name)
    return unless mailchimp_enabled?

    mailchimp_client.lists.update_member(
      id:           MAILCHIMP_LISTS[:all_users],
      email:        { email: email },
      merge_vars:   {
        groupings: [
          { id:     MAILCHIMP_GROUPINGS[:powur_path],
            groups: [ group_name ] }
        ]
      })
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
