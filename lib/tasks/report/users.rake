namespace :powur do
  namespace :report do
    def csv_field_names
      %w(id name email phone)
    end

    def csv_data(user)
      [ user.id, user.full_name, user.email, user.phone ]
    end

    task partners: :environment do
      CSV.open('/tmp/powur_partners.csv', 'w') do |csv|
        csv << csv_field_names
        User.partners.each do |user|
          csv << csv_data(user)
        end
      end
    end

    task :user_team, [:user_id] => :environment do |_task, args|
      CSV.open('/tmp/user_team.csv', 'w') do |csv|
        csv << csv_field_names
        User.all_team(args.user_id).each do |user|
          csv << csv_data(user)
        end
      end
    end
  end
end
