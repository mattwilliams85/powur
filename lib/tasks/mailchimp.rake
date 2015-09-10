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
end
