module Admin

  class OrdersController < AdminController
    include SortAndPage

    SORTS = { 
      order_date: { order_date: :desc },
      customer:   'customers.last_name asc',
      user:       'users.last_name asc' }

    sort_and_page available_sorts: SORTS

    def index(query = Order)
      respond_to do |format|
        format.html { render 'index' }
        format.json do
          query = query.
            includes(:user, :product, :customer).
            references(:user, :product, :customer)
          @orders = sort_and_page(query)

          render 'index'
        end
      end
    end

    def search
      query = Order.user_customer_search(params[:search])

      index(query)
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
