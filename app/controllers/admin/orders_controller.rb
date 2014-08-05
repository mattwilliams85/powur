module Admin

  class OrdersController < AdminController

    def create
      quote = Quote.find(params[:quote_id].to_i)

      
    end
  end

end