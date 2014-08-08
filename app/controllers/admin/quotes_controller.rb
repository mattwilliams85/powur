module Admin

  class QuotesController < AdminController
    # include SortAndPage

    helper_method :total_pages

    # sort_and_page a: 1

    def index(query = Quote)
      respond_to do |format|
        format.html { render 'index' }
        format.json do
          @quotes = query.
            includes(:user, :product, :customer).
            references(:user, :product, :customer).
            order(order).limit(limit).offset(offset)

          render 'index'
        end
      end

    end

    def search
      query = Quote.user_customer_search(params[:search])

      index(query)
    end

    private

    ORDERS = { 
      created:  { created_at: :desc },
      customer: 'customers.last_name asc',
      user:     'users.last_name asc' }

    def sort
      @sort ||= params[:sort] && ORDERS.keys.include?(params[:sort].to_sym) ?
        params[:sort].to_sym : :created_at
    end

    def order
      ORDERS[sort]
    end

    def limit
      @limit ||= params[:limit] ? params[:limit].to_i : 20
    end

    def page
      @page ||= params[:page] ? params[:page].to_i : 1
    end

    def total_pages
      @total_pages ||= begin
        total_count = @quotes.except(:offset, :limit, :order).count
        total_count / limit + (total_count % limit > 0 ? 1 : 0)
      end
    end

    def offset
      limit * (page - 1)
    end

  end
end
