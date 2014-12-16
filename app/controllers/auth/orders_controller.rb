module Auth
  class OrdersController < AuthController
    before_action :fetch_order, only: [ :show ]

    def index(query = Order)
      respond_to do |format|
        format.json do
          if params[:search].present?
            query = query.customer_search(params[:search])
          end
          query = apply_list_query_options(query)
                  .includes(:user, :customer, :product)
                  .references(:user, :customer, :product)
          @orders = query

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
      error!(:duplicate_order)
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
