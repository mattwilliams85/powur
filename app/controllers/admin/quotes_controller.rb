module Admin

  class QuotesController < AdminController

    def index(query = Quote)
      @quotes = query.
        includes(:user, :product, :customer).
        references(:user, :product, :customer).
        order(order).limit(limit).offset(offset)

      render 'index'
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

    # def total_pages
    #   @total_pages
    # end

    def offset
      limit * (page - 1)
    end

  end
end
