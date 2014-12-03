module Admin
  class SystemsController < AdminController
    def show
    end

    QUOTE_FIELDS = %w(customer_first_name customer_last_name customer_email
                      customer_phone customer_address_1 customer_city
                      customer_state customer_zip customer_utility
                      customer_average_bill customer_rate_schedule
                      customer_square_foot customer_id distributor_first_name
                      distributor_last_name distributor_id distribor)
    def quotes
      quotes = Quote.all
      if input[:start_date]
        quotes = quotes.where('created_at >= ?', input[:start_date].to_date)
      end
      send_data Quote.to_csv(quotes), filename: 'quotes.csv'
    end

    private

    def input
      allow_input(:start_date)
    end
  end
end
