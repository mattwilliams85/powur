module Admin
  class OrdersController < AdminController
    before_action :fetch_order, only: [ :show ]

    page
    sort order_date: { order_date: :desc },
         customer:   'customers.last_name asc, customers.first_name asc',
         user:       'users.last_name asc, users.first_name asc'

    def index(query = Order)
      respond_to do |format|
        format.html { render 'index' }
        format.json do
          @orders = format_index_query(query)

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

    def format_index_query(query)
      unless params[:search].blank?
        query = query.user_customer_search(params[:search])
      end
      apply_list_query_options(query)
        .includes(:user, :customer, :product)
        .references(:user, :customer, :product)
    end

    def input
      allow_input(:order_date)
    end

    def fetch_order
      @order = Order.find(params[:id].to_i)
    end
  end
end
