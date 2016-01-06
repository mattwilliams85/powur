namespace :powur do
  namespace :report do
    task :certs_by_user, [
      :user_id, :start_date, :end_date ] => :environment do |_t, args|

      user_id = args[:user_id].to_i
      start_date = Date.parse(args[:start_date]) if args[:start_date]
      end_date = Date.parse(args[:end_date]) if args[:end_date]

      purchases = ProductReceipt
        .joins(:user).references(:user)
        .where('? = ANY (users.upline) AND users.id != ?', user_id, user_id)
        .where(product_id: 3)
        .order(purchased_at: :asc)
      purchases = purchases.where('purchased_at >= ?', start_date) if start_date
      purchases = purchases.where('purchased_at <= ?', end_date) if end_date

      CSV.open("/tmp/certs_by_user_#{user_id}.csv", 'w') do |csv|
        csv << %w(user_id, name, email, date_of_purchase)
        purchases.each do |purchase|
          csv << [ purchase.user_id,
                   purchase.user.full_name,
                   purchase.user.email,
                   purchase.purchased_at.try(:to_s, :long) ]
        end
      end
    end
  end
end
