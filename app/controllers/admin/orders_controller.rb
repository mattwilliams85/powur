module Admin

  class OrdersController < AdminController

    def index
    end

    def create
      quote = Quote.find(params[:quote_id].to_i)

      attrs = input.merge(
        product:  quote.product,
        user:     quote.user,
        customer: quote.customer)
      attrs[:order_date] ||= DateTime.current

      @order = quote.create_order!(attrs)

      render 'show'
    rescue ActiveRecord::RecordNotUnique
      error! t('errors.duplicate_order')
    end

    private

    def input
      allow_input(:order_date)
    end
  end

end
