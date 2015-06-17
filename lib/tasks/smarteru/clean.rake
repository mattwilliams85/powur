namespace :powur do
  namespace :smarteru do
    def try_update_ee_id(user)
      result = user.smarteru.normalize_employee_id!
      if result
        puts "updated ee_id for #{user.id} : #{user.full_name}"
      else
        puts "account not found for #{user.id} : #{user.full_name}"
      end
    rescue Smarteru::Error => e
      fail(e) unless e.code == 'GU:04'
      puts "Cannot update user #{user.id} : #{user.full_name}"
    end

    task clean_ee_ids: :environment do
      users = User
        .where('smarteru_employee_id is not null')
        .where("smarteru_employee_id not like 'powur:%'")
        .limit(10)

      users.each { |user| try_update_ee_id(user) }
    end

    task hydrate_ee_ids: :environment do
      users = User
        .where('smarteru_employee_id is null')
        .order(:id)
        .limit(25)
      users = users.where('id > ?', ENV['USER_ID'].to_i) if ENV['USER_ID']

      users.each { |user| try_update_ee_id(user) }
    end
  end
end

