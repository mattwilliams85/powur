module Admin

  class QuotesController < AdminController

    def index(query = Quote)
      @quotes = query.
        includes(:user, :product, :customer).
        order(order).limit(limit).offset(offset)

      render 'index'
    end

    def search

    end

    private

    ORDERS = { 
      created_at: { created_at: :desc },
      customer:   'customers.last_name asc',
      user:       'users.last_name asc' }
    def order
      @order ||= params[:sort] ? ORDERS[params[:sort].to_sym] : ORDERS[:created_at]
    end

    def limit
      @limit ||= params[:limit] ? params[:limit].to_i : 20
    end

    def offset
      @offset ||= params[:p] ? limit * (params[:p].to_i - 1) : 0
    end

  end
end
