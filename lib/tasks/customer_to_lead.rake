namespace :powur do
  def find_or_create_lead(product, customer)
    attrs = { product_id: product.id, customer_id: customer.id }
    Lead.find_or_create_by(attrs) do |lead|
      lead.user_id = customer.user_id
    end
  end

  task customer_to_lead: :environment do
    Customer.find_each do |customer|
      next unless customer.user_id
      lead = find_or_create_lead(Product.default, customer)
      keys = %w(first_name last_name email phone address city state zip notes
                code last_viewed_at mandrill_id)
      attrs = customer.attributes
        .select { |k, v| keys.include?(k) && v.present? }
      if customer.attributes['status']
        # move old statuses ahead because of the new initial status
        attrs['invite_status'] = customer.attributes['status'] + 1
      end
      lead.update_columns(attrs) unless attrs.empty?
    end
  end
end
