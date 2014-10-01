module Auth

  class OrdersController < AuthController
    include SortAndPage

    before_filter :fetch_order, only: [ :show ]

    SORTS = {
      order_date: { order_date: :desc },
      customer:   'customers.last_name asc',
      user:       'users.last_name asc' }

    sort_and_page available_sorts: SORTS

    def index(query = Order)
      respond_to do |format|
        format.json do
          query = query.
            includes(:user, :customer, :product).
            references(:user, :customer, :product)
          unless params[:search].blank?
            query = query.user_customer_search(params[:search])
          end
          @orders = page!(query)

          render 'index'
        end
      end
    end

    def create
      quote = Quote.find(params[:quote_id].to_i)

      attrs = input.merge(
        product:  quote.product,
        user:     quote.user,
        customer: quote.customer)
      attrs['order_date'] ||= DateTime.current

      @order = quote.create_order!(attrs)

      render 'show'
    rescue ActiveRecord::RecordNotUnique
      error! t('errors.duplicate_order')
    end

    def show
    end

    private

    def input
      allow_input(:order_date)
    end

    def fetch_order
      @order = Order.find(params[:id].to_i)
    end

  end

end
