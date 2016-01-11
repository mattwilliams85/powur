namespace :powur do
  desc 'Update subscribed users with their mailchimp id'
  task update_mailchimp_id: :environment do
    client = Gibbon::Request.new
    members = client.lists(User::MAILCHIMP_LISTS[:all_users])
      .members.retrieve(params: {offset: 0, count: 1000})['members']
    members.each do |m|
      user = User.find_by(email: m['email_address'])
      user.update_attribute(:mailchimp_id, m['id']) if user
    end
  end

  desc 'Subscribe users that do not have mailchimp id'
  task subscribe_to_mailchimp: :environment do
    User.where("exist(profile, 'mailchimp_id') = false").find_each do |user|
      begin
        user.mailchimp_subscribe
      rescue Gibbon::MailChimpError
        puts "Error subscribing: #{user.email}"
      end
    end
  end
end
