module Admin

  class OrdersController < AdminController
    include SortAndPage

    helper_method :total_pages

    sort_and_page

    def available_sorts
      SORTS
    end

    def index(query = Order)
      @orders = sort_and_page(query)

      render 'index'
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

    SORTS = { 
      order_date: { order_date: :desc },
      customer:   'customers.last_name asc',
      user:       'users.last_name asc' }

    def items
      @items ||= begin

      end
    end

    private

    def input
      allow_input(:order_date)
    end

    def available_sorts
      SORTS
    end

    # def sort_order
    #   @sort_order ||= begin
    #     key = params[:sort] && available_sorts.keys.include?(params[:sort].to_sym) ?
    #       params[:sort].to_sym : available_sorts.keys.first
    #     available_sorts[key]
    #   end
    # end

    # def limit
    #   @limit ||= params[:limit] ? params[:limit].to_i : 20
    # end

    # def page
    #   @page ||= params[:page] ? params[:page].to_i : 1
    # end

    # def total_pages
    #   @total_pages ||= begin
    #     total_count = @quotes.except(:offset, :limit, :order).count
    #     total_count / limit + (total_count % limit > 0 ? 1 : 0)
    #   end
    # end

    # def offset
    #   limit * (page - 1)
    # end

  end

end
