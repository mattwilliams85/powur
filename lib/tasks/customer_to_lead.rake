namespace :powur do
  task customer_to_lead: :environment do
    Lead.joins(:customer).includes(:customer).find_each do |l|
      keys = %w(first_name last_name email phone address city state zip notes)
      attrs = l.customer.attributes
        .select { |k, v| keys.include?(k) && v.present? }
      l.update_columns(attrs) unless attrs.empty?
    end
  end
end
