namespace :powur do
  namespace :report do
    task partners: :environment do
      CSV.open('/tmp/powur_partners.csv', 'w') do |csv|
        csv << %w(id name email, phone)
        User.partners.each do |user|
          csv << [ user.id, user.full_name, user.email, user.phone ]
        end
      end
    end
  end
end
