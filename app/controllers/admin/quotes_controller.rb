module Admin

  class QuotesController < AdminController
    include SortAndPage

    before_action :fetch_quote, only: [ :show ]

    SORTS = { 
      created:  { created_at: :desc },
      customer: 'customers.last_name asc',
      user:     'users.last_name asc' }

    sort_and_page available_sorts: SORTS

    def index(query = Quote)
      respond_to do |format|
        format.html { render 'index' }
        format.json do
          query = query.
            includes(:user, :product, :customer).
            references(:user, :product, :customer)
          @quotes = page!(query)

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
