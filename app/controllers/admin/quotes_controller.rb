module Admin
  class QuotesController < AdminController

    before_action :fetch_quote, only: [ :show ]

    page
    sort created:  { created_at: :desc },
         customer: 'customers.last_name asc',
         user:     'users.last_name asc'

    def index(query = Quote)
      respond_to do |format|
        format.html { render 'index' }
        format.json do
          @quotes = apply_list_query_options(query)
            .includes(:user, :product, :customer)
            .references(:user, :product, :customer)
          render 'index'
        end
      end
    end

    def show
    end

    def search
      query = Quote.user_customer_search(params[:search])

      index(query)
    end

    private

    def fetch_quote
      @quote = Quote.find(params[:id].to_i)
    end
  end
end
